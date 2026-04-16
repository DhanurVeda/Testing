//
//  RecordingView.swift
//  Testing
//
//  Created by Yashika Sharma on 06/04/26.
//

import SwiftUI
import AVKit

struct RecordingView: View {
    
    @State private var vm = RecordingViewModel()
    
    var body: some View {
        ZStack {
            
            if let url = vm.outputURL {
                VideoPlayer(player: AVPlayer(url: url))
                    .id(UUID()) // force reload
                    .ignoresSafeArea()
            } else {
                CameraPreview(session: vm.camera.session)
                    .ignoresSafeArea()
            }
            
            VStack {
                Spacer()
                
                Button(vm.isRecording ? "Stop" : "Record") {
                    if vm.isRecording {
                        vm.stopRecording()
                    } else {
                        vm.startRecording()
                    }
                }
                .padding()
                .background(.red)
                .foregroundColor(.white)
                
                Text(vm.feedback)
                    .padding()
                    .foregroundColor(.white)
            }
        }
        .onAppear {
            vm.setup()
        }
    }
}
#Preview {
    RecordingView()
}
