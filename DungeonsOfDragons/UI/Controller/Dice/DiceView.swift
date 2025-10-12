//
//  DiceView.swift
//  DungeonsOfDragons
//
//  Created by Pavlov Boris on 12.10.2025.
//

import SwiftUI

struct DiceModalView: View {
    @Binding var isPresented: Bool
    @State private var diceNumber = 1
    @State private var animate = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .onTapGesture {
                    dismissWithAnimation()
                }

            ZStack(alignment: .topTrailing) {
                VStack(spacing: 20) {
                    Spacer()
                    
                    Text("Экран в разработке") // 🎲 Dice: \(diceNumber)")
                        .font(.largeTitle)
                        .bold()
                    
//                    Button("Roll Dice") {
//                        diceNumber = Int.random(in: 1...6)
//                    }
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    
                    Spacer()
                }
                .padding(20)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color(hex: "1A1A2E"), Color(hex: "FF4500")]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .cornerRadius(16)
                .shadow(radius: 10)
                
                Button(action: { dismissWithAnimation() }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .font(.title)
                }
                .padding([.top, .trailing], 10)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 24)
            .scaleEffect(animate ? 1 : 0.8)
            .opacity(animate ? 1 : 0)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.3)) {
                animate = true
            }
        }
    }
    
    private func dismissWithAnimation() {
        withAnimation(.easeInOut(duration: 0.3)) {
            animate = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isPresented = false
        }
    }
}
