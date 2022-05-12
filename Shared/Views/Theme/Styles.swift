//
//  Theme.swift
//  punkwallet
//
//  Created by mwrites on 2022/4/29.
//

import SwiftUI


struct AsyncButton<Label: View>: View {
    var action: () async -> Void
    @ViewBuilder var label: () -> Label
    
    @State private var isPerformingTask = false
    
    var body: some View {
        Button(
            action: {
                isPerformingTask = true
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                Task {
                    await action()
                    isPerformingTask = false
                }
            },
            label: {
                ZStack {
                    // We hide the label by setting its opacity
                    // to zero, since we don't want the button's
                    // size to change while its task is performed:
                    label().opacity(isPerformingTask ? 0 : 1)
                    
                    if isPerformingTask {
                        ProgressView()
                    }
                }
            }
        )
        .disabled(isPerformingTask)
        .buttonStyle(GrowingButton())
    }
}


struct GrowingButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Theme.buttonActionColor)
            .foregroundColor(.white)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}


struct ClearButton: ViewModifier
{
    @Binding var text: String
    
    public func body(content: Content) -> some View {
        ZStack(alignment: .trailing) {
            content
            
            if !text.isEmpty {
                Button(action:
                        {
                    self.text = ""
                })
                {
                    Image(systemName: "delete.left")
                        .foregroundColor(Color(UIColor.opaqueSeparator))
                }
                .padding(.trailing, 8)
            }
        }
    }
}

struct TappableZone: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(height: 30)
            .padding()
            .background(Color(red: 0, green: 0, blue: 0, opacity: 0.05))
            .cornerRadius(45)
    }
}

struct SmallButtonStyle: ButtonStyle {
    var fgColor = Color(red: 0, green: 0, blue: 0, opacity: 0.5)
    var bgColor = Color(red: 0, green: 0, blue: 0, opacity: 0.1)
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Font.callout.weight(.bold))
            .padding(8)
            .frame(height: 26)
            .foregroundColor(fgColor)
            .background(bgColor)
            .cornerRadius(15)
    }
}


struct TextFieldAmountStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(Font.title.weight(.bold))
            .keyboardType(.decimalPad)
    }
}
