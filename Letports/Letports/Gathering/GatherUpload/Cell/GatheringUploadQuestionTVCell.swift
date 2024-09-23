import UIKit
import KoTextCountLimit

class GatheringUploadQuestionTVCell: UITableViewCell {
    private let koTextLimit = KoTextCountLimit()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .lp_Font(.regular, size: 18)
        label.text = "사전질문"
        label.textColor = .lp_black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var contentTextView: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = .lp_white
        tv.textColor = .lp_black
        tv.font = .lp_Font(.regular, size: 15)
        tv.layer.cornerRadius = 10
        tv.isScrollEnabled = true
        tv.delegate = self
        tv.textContainerInset = UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private let textCountLabel: UILabel = {
        let label = UILabel()
        label.text = "0/1000"
        label.textColor = .lp_gray
        label.font = .lp_Font(.regular, size: 10)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    weak var delegate: GatheringUploadDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        self.backgroundColor = .lp_background_white
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Setup UI
    private func setupUI() {
        [titleLabel, contentTextView, textCountLabel].forEach {
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            contentTextView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 11),
            contentTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            contentTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            contentTextView.heightAnchor.constraint(equalToConstant: 250),
            textCountLabel.topAnchor.constraint(equalTo: contentTextView.bottomAnchor, constant: 14),
            textCountLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor),
            textCountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textCountLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),
            textCountLabel.heightAnchor.constraint(equalToConstant: 15)
        ])
    }
   
    func configureCell(question: String?) {
        guard let questionText = question else { return }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        
        let attributedText = NSAttributedString(
            string: questionText,
            attributes: [
                .font: UIFont.lp_Font(.regular, size: 15),
                .foregroundColor: UIColor.lp_black,
                .paragraphStyle: paragraphStyle
            ]
        )
        
        self.contentTextView.attributedText = attributedText
        self.textCountCheck(text: questionText)
    }
    
    private func textCountCheck(text: String) {
        DispatchQueue.main.async { [weak self] in
            self?.textCountLabel.text = "\(text.count)/1000"
        }
    }
}

extension GatheringUploadQuestionTVCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        
        let attributedText = NSAttributedString(
            string: textView.text,
            attributes: [
                .font: UIFont.lp_Font(.regular, size: 15),
                .foregroundColor: UIColor.lp_black,
                .paragraphStyle: paragraphStyle
            ]
        )
        
        self.contentTextView.attributedText = attributedText
        self.textCountCheck(text: textView.text)
        delegate?.sendGatherQuestion(content: textView.text)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return koTextLimit.shouldChangeText(for: textView, in: range,replacementText: text, maxCharacterLimit: 1000)
    }
}
