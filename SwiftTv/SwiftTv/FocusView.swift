
import SwiftUI

struct FocusView<Content>: UIViewRepresentable where Content : View {

    typealias UIViewType = UIFocusView<Content>

    var content: () -> Content
    private let onFocusChange: (Bool) -> Void
    private var onTap: ((UIGestureRecognizer.State) -> Void)?

    public init(onFocusChange: @escaping (Bool) -> Void,
                onTap: ((UIGestureRecognizer.State) -> Void)? = nil,
                @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.onFocusChange = onFocusChange
        self.onTap = onTap
    }

    func makeUIView(context: Context) -> UIViewType {
        return UIFocusView(content: content, onFocusChange: onFocusChange, onTap: onTap)
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        //print("update ui view")
        uiView.updateContent(content)
    }

//    static func dismantleUIView(_ uiView: UIViewType, coordinator: Coordinator) {
//
//    }
}

final class UIFocusView<Content: View> : UIView {//, ObservableObject {

    private var lastBounds = CGSize.zero

    private var content: () -> Content
    private let host: UIHostingController<Content>
    private let onFocusChange: (Bool) -> Void
    private let onTap: ((UIGestureRecognizer.State) -> Void)?

    init(content: @escaping () -> Content,
         onFocusChange: @escaping (Bool) -> Void,
         onTap: ((UIGestureRecognizer.State) -> Void)?) {

        self.content = content
        self.onFocusChange = onFocusChange
        self.onTap = onTap

        host = UIHostingController<Content>(rootView: content())

        super.init(frame: .zero)

        self.backgroundColor = .clear
        host.view.backgroundColor = .clear

        self.addSubview(host.view)

        addGestureRecognizer(UITapGestureRecognizer(target: self, action: nil))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateContent(_ content: @escaping () -> Content) {
        self.content = content
        host.rootView = content()
    }

    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        if presses.contains(where: { $0.type == .select }) {
            onTap?(UIGestureRecognizer.State.began)
        }
        super.pressesBegan(presses, with: event)
    }
    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        if presses.contains(where: { $0.type == .select }) {
            onTap?(UIGestureRecognizer.State.ended)
        }
        super.pressesEnded(presses, with: event)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return host.sizeThatFits(in: size)
    }

    override var intrinsicContentSize: CGSize {
        return host.view.intrinsicContentSize
    }

    override var canBecomeFocused: Bool {
        return true
    }

    override func didUpdateFocus(in context: UIFocusUpdateContext,
                   with coordinator: UIFocusAnimationCoordinator) {

        if context.nextFocusedView == self {
            onFocusChange(true)
        }

        if context.previouslyFocusedView == self {
            onFocusChange(false)
        }
    }

    override func layoutSubviews() {
        if lastBounds != frame.size {
            lastBounds = frame.size
            host.view.frame = CGRect(origin: .zero, size: lastBounds)
        }
    }

}
