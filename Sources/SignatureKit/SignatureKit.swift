import SwiftUI
import Foundation
import PencilKit


let minSignatureSize = CGSize(width: 30, height: 30)

public struct SignatureKit {
    public private(set) var text = "Hello, World!"

    public init() {
    }
}


@available(iOS 13.0, *)
struct DrawSignatureView: View {
    
    @Environment(\.presentationMode) private var presentation
    @State private var presentAlert = false
    @State private var canvasView = PKCanvasView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
    @State var signImage: UIImage
    @State var isSignatureBlank: Bool
    var signatureCapturedClosure: ((Bool,UIImage)-> Void)
    
    private func thubmnailSignature() {
        isSignatureBlank = false
        let drawing = canvasView.drawing
        if drawing.dataRepresentation().isEmpty { isSignatureBlank = true;  return }
        signImage =  drawing.image(from: drawing.bounds, scale: 3.0)
    }
    private func isSignatureLegible() -> Bool {
        return signImage.size.width > minSignatureSize.width &&
        signImage.size.height > minSignatureSize.height
    }
    
    var body: some View {
        NavigationView {
            VStack {
                PencilKitRepresentable(canvasView: $canvasView)
            }
            .navigationBarTitle("Add Signature")
            .navigationBarItems(leading: Button(action: {
                canvasView.drawing = PKDrawing()
            }, label: {
                Image(systemName: "trash.circle.fill")
                    .resizable()
                    .frame(width: 25, height: 25)
                    .foregroundColor(.black)
            }) ,
                                trailing: Button(action: {
                thubmnailSignature()
                presentAlert = !isSignatureLegible()
                if !presentAlert {
                    self.signatureCapturedClosure(isSignatureBlank, signImage)
                }
            }, label: {
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .frame(width: 25, height: 25)
                    .foregroundColor(.black)
            })
                                    .alert(isPresented: $presentAlert, content: {
                Alert(title: Text("Error"), message: Text("Please draw legible signatures"))
            })
            )
        }
    }
}


@available(iOS 13.0, *)
struct PencilKitRepresentable : UIViewRepresentable {
    
    @Binding var canvasView: PKCanvasView
    func makeUIView(context: Context) -> PKCanvasView {
        if #available(iOS 14.0, *) {
            canvasView.drawingPolicy = .anyInput
        } else {
            // Fallback on earlier versions
        }
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 5)
        canvasView.allowsFingerDrawing = true
        return canvasView
    }
    func updateUIView(_ uiView: PKCanvasView, context: Context) {}
}








