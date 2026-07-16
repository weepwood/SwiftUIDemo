import SwiftUI

extension View {
    /// Uses native Liquid Glass on macOS 26 and later while preserving the
    /// existing material-based appearance on macOS 14 and 15.
    @ViewBuilder
    func adaptiveGlass(
        cornerRadius: CGFloat = 20,
        tint: Color? = nil
    ) -> some View {
        if #available(macOS 26.0, *) {
            if let tint {
                self.glassEffect(
                    .regular.tint(tint),
                    in: .rect(cornerRadius: cornerRadius)
                )
            } else {
                self.glassEffect(
                    .regular,
                    in: .rect(cornerRadius: cornerRadius)
                )
            }
        } else {
            self
                .background(
                    .regularMaterial,
                    in: RoundedRectangle(
                        cornerRadius: cornerRadius,
                        style: .continuous
                    )
                )
                .overlay {
                    RoundedRectangle(
                        cornerRadius: cornerRadius,
                        style: .continuous
                    )
                    .stroke(.separator.opacity(0.35), lineWidth: 1)
                }
        }
    }

    /// Applies the matching system button style for the running macOS release.
    @ViewBuilder
    func adaptiveGlassButtonStyle(prominent: Bool = false) -> some View {
        if #available(macOS 26.0, *) {
            if prominent {
                self.buttonStyle(.glassProminent)
            } else {
                self.buttonStyle(.glass)
            }
        } else {
            if prominent {
                self.buttonStyle(.borderedProminent)
            } else {
                self.buttonStyle(.bordered)
            }
        }
    }
}
