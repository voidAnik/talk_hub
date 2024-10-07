import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:talk_hub/core/web_rtc/enums.dart';
import 'package:talk_hub/core/web_rtc/firebase_constants.dart';

typedef StreamTrackCallback = void Function(MediaStream stream);
typedef ErrorCallback = void Function(String error);
typedef PeerCallback = void Function();

class Signaling {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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
  late StreamTrackCallback onAddLocalStream, onAddRemoteStream;
  late PeerCallback onRemoveRemoteStream, onDisconnect;
  String? callId;

  MediaType mediaType;

  Signaling(this.mediaType);

  // This function initiates the call
  Future<void> initiateCall(String callerId, String receiverId) async {
    // Create a new call document in Firestore
    DocumentReference callRef =
        _firestore.collection(FirebaseConst.callsCollection).doc();
    callId = callRef.id;

    // Get local media stream (audio and video)
    _localStream = await _getUserMedia();

    if (mediaType == MediaType.video) {
      onAddLocalStream(_localStream);
    }

    _rtcPeerConnection = await createPeerConnection(_configurationServer);
    registerPeerConnectionListeners();

    // Add local stream tracks to the peer connection
    _localStream.getTracks().forEach((track) {
      _rtcPeerConnection.addTrack(track, _localStream);
    });

    // Collect ICE candidates
    _rtcPeerConnection.onIceCandidate = (RTCIceCandidate candidate) {
      if (candidate == null) {
        log('Got final candidate!');
        return;
      }
      final candidateMap = candidate.toMap();
      log('Got candidate: $candidateMap');
      callRef
          .collection(FirebaseConst.callerCandidatesCollection)
          .add(candidateMap);
    };

    // Create an SDP offer
    final offer = await _rtcPeerConnection.createOffer(offerSdpConstraints);
    await _rtcPeerConnection.setLocalDescription(offer);

    // Store offer information in the call document
    await callRef.set({
      FirebaseConst.offerField: offer.toMap(),
      FirebaseConst.callerIdField: callerId,
      FirebaseConst.receiverIdField: receiverId,
      FirebaseConst.callStatusField: CallStatus.ringing.name,
      FirebaseConst.callTypeField: mediaType.name,
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
    callRef
        .collection(FirebaseConst.calleeCandidatesCollection)
        .snapshots()
        .listen((snapshot) {
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
      if (event.track.kind == 'video') {
        onAddRemoteStream.call(event.streams[0]);
        log('Got remote track: ${event.streams[0]}');
      }
    };
  }

  // Function for the receiver to answer the call
  Future<void> answerCall(String callId) async {
    final callRef = _firestore.collection('calls').doc(callId);
    final callSnapshot = await callRef.get();

    if (callSnapshot.exists) {
      _localStream = await _getUserMedia();

      if (mediaType == MediaType.video) {
        onAddLocalStream(_localStream);
      }

      _rtcPeerConnection = await createPeerConnection(_configurationServer);
      registerPeerConnectionListeners();

      // Add local stream tracks
      _localStream.getTracks().forEach((track) {
        _rtcPeerConnection.addTrack(track, _localStream);
      });

      // Add onTrack event listener for remote stream
      _rtcPeerConnection.onTrack = (RTCTrackEvent event) {
        if (event.track.kind == 'video') {
          onAddRemoteStream.call(event.streams[0]);
          log('Got remote track: ${event.streams[0]}');
        }
      };

      // Handle the offer from the caller
      final offer = callSnapshot.data()?[FirebaseConst.offerField];
      await _rtcPeerConnection.setRemoteDescription(
        RTCSessionDescription(offer['sdp'], offer['type']),
      );

      // Create an SDP answer
      final answer = await _rtcPeerConnection.createAnswer(offerSdpConstraints);
      await _rtcPeerConnection.setLocalDescription(answer);

      // Update the call document with the answer
      await callRef.update({
        FirebaseConst.answerField: answer.toMap(),
        FirebaseConst.callStatusField: CallStatus.answered.name,
      });

      // Listen for remote ICE candidates
      callRef
          .collection(FirebaseConst.callerCandidatesCollection)
          .snapshots()
          .listen((snapshot) {
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

    if (mediaType == MediaType.video) {
      onRemoveRemoteStream();
    }

    if (_rtcPeerConnection != null) {
      _rtcPeerConnection.close();
    }

    // Delete call document from Firestore
    if (callId.isNotEmpty) {
      await _firestore
          .collection(FirebaseConst.callsCollection)
          .doc(callId)
          .delete();
    }
  }

  void registerPeerConnectionListeners() {
    _rtcPeerConnection.onIceGatheringState = (RTCIceGatheringState state) {
      log('ICE gathering state changed: $state');
    };

    _rtcPeerConnection.onConnectionState = (RTCPeerConnectionState state) {
      log('Connection state change: $state');
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
      log('Signaling state change: $state');
    };

    _rtcPeerConnection.onIceConnectionState = (RTCIceConnectionState state) {
      log('ICE connection state change: $state');
    };
  }

  Future<MediaStream> _getUserMedia() async {
    if (mediaType == MediaType.video) {
      return await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': {
          'facingMode': 'user',
        },
      });
    } else {
      return await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': false,
      });
    }
  }
}
