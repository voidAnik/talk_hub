import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class Signaling {
  FirebaseFirestore db = FirebaseFirestore.instance;
  final Map<String, dynamic> _configurationServer = {
    'iceServers': [
      {
        'urls': [
          'stun:stun1.l.google.com:19302',
          'stun:stun2.l.google.com:19302',
        ],
      },
    ],
    'sdpSemantics': 'unified-plan',
  };

  final Map<String, dynamic> offerSdpConstraints = {
    "mandatory": {
      "OfferToReceiveAudio": true,
      "OfferToReceiveVideo": true,
    },
    "optional": [],
  };

  late RTCPeerConnection _rtcPeerConnection;
  late MediaStream _localStream;
  late Function(MediaStream stream) onLocalStream;
  late Function(MediaStream stream) onAddRemoteStream;
  late Function() onRemoveRemoteStream;
  late Function() onDisconnect;

  // This function initiates the call
  Future<void> initiateCall(
      String callerId, String receiverId, String callType) async {
    // Create a new call document in Firestore
    DocumentReference callRef = db.collection('calls').doc();

    // Get local media stream (audio and video)
    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': {
        'facingMode': 'user',
      },
    });

    onLocalStream.call(_localStream);

    _rtcPeerConnection = await createPeerConnection(_configurationServer);
    registerPeerConnectionListeners();

    // Add local stream tracks to the peer connection
    _localStream.getTracks().forEach((track) {
      _rtcPeerConnection.addTrack(track, _localStream);
    });

    // Collect ICE candidates
    _rtcPeerConnection.onIceCandidate = (RTCIceCandidate candidate) {
      if (candidate == null) {
        print('Got final candidate!');
        return;
      }
      final candidateMap = candidate.toMap();
      print('Got candidate: $candidateMap');
      callRef.collection('callerCandidates').add(candidateMap);
    };

    // Create an SDP offer
    final offer = await _rtcPeerConnection.createOffer(offerSdpConstraints);
    await _rtcPeerConnection.setLocalDescription(offer);

    // Store offer information in the call document
    await callRef.set({
      'offer': offer.toMap(),
      'callerId': callerId,
      'receiverId': receiverId,
      'callStatus': 'ringing',
      'callType': callType,
    });

    // Listen for remote SDP answer
    callRef.snapshots().listen((snapshot) async {
      final data = snapshot.data() as Map<String, dynamic>?;
      if (data != null && data.containsKey('answer')) {
        final rtcSessionDescription = RTCSessionDescription(
          data['answer']['sdp'],
          data['answer']['type'],
        );
        await _rtcPeerConnection.setRemoteDescription(rtcSessionDescription);
      }
    });

    // Listen for remote ICE candidates
    callRef.collection('calleeCandidates').snapshots().listen((snapshot) {
      snapshot.docChanges.forEach((change) async {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data();
          await _rtcPeerConnection.addCandidate(RTCIceCandidate(
            data?['candidate'],
            data?['sdpMid'],
            data?['sdpMlineIndex'],
          ));
        }
      });
    });

    // Add onTrack event listener
    _rtcPeerConnection.onTrack = (RTCTrackEvent event) {
      onAddRemoteStream.call(event.streams[0]);
      print('Got remote track: ${event.streams[0]}');
    };
  }

  // Function for the receiver to answer the call
  Future<void> answerCall(String callId) async {
    final callRef = db.collection('calls').doc(callId);
    final callSnapshot = await callRef.get();

    if (callSnapshot.exists) {
      _localStream = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': {
          'facingMode': 'user',
        },
      });
      onLocalStream.call(_localStream);

      _rtcPeerConnection = await createPeerConnection(_configurationServer);
      registerPeerConnectionListeners();

      // Add local stream tracks
      _localStream.getTracks().forEach((track) {
        _rtcPeerConnection.addTrack(track, _localStream);
      });

      // Handle the offer from the caller
      final offer = callSnapshot.data()?['offer'];
      await _rtcPeerConnection.setRemoteDescription(
        RTCSessionDescription(offer['sdp'], offer['type']),
      );

      // Create an SDP answer
      final answer = await _rtcPeerConnection.createAnswer(offerSdpConstraints);
      await _rtcPeerConnection.setLocalDescription(answer);

      // Update the call document with the answer
      await callRef.update({
        'answer': answer.toMap(),
        'callStatus': 'answered',
      });

      // Listen for remote ICE candidates
      callRef.collection('callerCandidates').snapshots().listen((snapshot) {
        snapshot.docChanges.forEach((change) async {
          if (change.type == DocumentChangeType.added) {
            final data = change.doc.data();
            await _rtcPeerConnection.addCandidate(RTCIceCandidate(
              data?['candidate'],
              data?['sdpMid'],
              data?['sdpMlineIndex'],
            ));
          }
        });
      });

      // Add onTrack event listener for remote stream
      _rtcPeerConnection.onTrack = (RTCTrackEvent event) {
        onAddRemoteStream.call(event.streams[0]);
        print('Got remote track: ${event.streams[0]}');
      };
    }
  }

  // Mute microphone function
  void muteMic() {
    if (_localStream != null) {
      bool enabled = _localStream.getAudioTracks()[0].enabled;
      _localStream.getAudioTracks()[0].enabled = !enabled;
    }
  }

  // Hang up function
  Future<void> hangUp(String callId) async {
    _localStream.getTracks().forEach((track) {
      track.stop();
    });

    onRemoveRemoteStream();

    if (_rtcPeerConnection != null) {
      _rtcPeerConnection.close();
    }

    // Delete call document from Firestore
    if (callId.isNotEmpty) {
      await db.collection('calls').doc(callId).delete();
    }
  }

  void registerPeerConnectionListeners() {
    _rtcPeerConnection.onIceGatheringState = (RTCIceGatheringState state) {
      print('ICE gathering state changed: $state');
    };

    _rtcPeerConnection.onConnectionState = (RTCPeerConnectionState state) {
      print('Connection state change: $state');
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected) {
        _localStream.getTracks().forEach((track) {
          track.stop();
        });

        onRemoveRemoteStream();

        if (_rtcPeerConnection != null) {
          _rtcPeerConnection.close();
        }

        onDisconnect();
      }
    };

    _rtcPeerConnection.onSignalingState = (RTCSignalingState state) {
      print('Signaling state change: $state');
    };

    _rtcPeerConnection.onIceConnectionState = (RTCIceConnectionState state) {
      print('ICE connection state change: $state');
    };
  }
}
