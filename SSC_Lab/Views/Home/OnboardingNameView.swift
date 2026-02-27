//
//  OnboardingNameView.swift
//  SSC_Lab
//
//

import SwiftUI

struct OnboardingNameView: View {
    @Binding var userName: String
    @Binding var hasOnboarded: Bool
    @Environment(\.dismiss) private var dismiss
    
    @State private var nameInput: String = ""
    @FocusState private var isFocused: Bool
    
    @State private var isRecordingAction: Bool = false
    
    private let myPadding: CGFloat = 16

    var body: some View {
        ZStack {
            Color.appBg.ignoresSafeArea()
            
            VStack(spacing: 0) {

                headerView
                    .padding(.horizontal, myPadding)
                    .padding(.top, 32)
                
                Spacer()
                

                VStack(spacing: 24) {
                    Text("What should we record you as?")
                        .font(.appHeroSmall)
                        .foregroundStyle(Color.appFont)
                        .multilineTextAlignment(.center)
                    
                    TextField("Record me as...", text: $nameInput)
                        .font(.appBody)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.appFont, lineWidth: 1.5)
                                )
                        )
                        .focused($isFocused)
                        .disabled(isRecordingAction)
                        .accessibilityLabel("Enter your name here")
                                           
                }
                .padding(.horizontal, myPadding)
                
                Spacer()
                
                Button {
                    startRecordingSequence()
                } label: {
                    HStack(spacing: 8) {
                        if isRecordingAction {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 10, height: 10)
                            Text("REC")
                        } else {
                            Text("START RECORDING")
                        }
                    }
                    .font(.appSubHeadline)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 16)
                    .background(isRecordingAction ? Color.red : Color.appPrimary)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
                    .scaleEffect(isRecordingAction ? 1.05 : 1.0)
                }
                .disabled(nameInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isRecordingAction)
                .opacity(nameInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?   0.3 : 1)
                .padding(.bottom, 40)
                .accessibilityLabel(isRecordingAction ? "Recording in progress" : "Confirm name and start recording")
                .accessibilityHint("Double tap to save your name and enter the lab")
                            
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }

    private var headerView: some View {
        HStack {

            Text(isRecordingAction ? "REC" : "STBY")
                .foregroundStyle(isRecordingAction ? Color.red : Color.appSecondary)
            Spacer()
            Text("00:00")
        }
        .font(.system(size: 14, weight: .bold, design: .monospaced))
        .foregroundStyle(Color.appSecondary)
    }

    private func startRecordingSequence() {
        isFocused = false
        
        withAnimation(.easeInOut(duration: 0.3)) {
            isRecordingAction = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            userName = nameInput.trimmingCharacters(in: .whitespacesAndNewlines)
            hasOnboarded = true
            dismiss()
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var previewName = ""
        @State private var previewOnboarded = false
        
        var body: some View {
            OnboardingNameView(
                userName: $previewName,
                hasOnboarded: $previewOnboarded
            )
        }
    }
    
    return PreviewWrapper()
}
