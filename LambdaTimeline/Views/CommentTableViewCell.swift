//
//  CommentTableViewCell.swift
//  LambdaTimeline
//
//  Created by Kobe McKee on 7/9/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {

    var comment: Comment? {
        didSet {
            updateViews()
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
    
    
    func updateViews() {
        guard let comment = comment else { return }
        if comment.text != nil {
            commentLabel.isHidden = true
        } else {
            playButton.isHidden = true
            commentLabel.text = comment.text
        }
        
        nameLabel.text = comment.author.displayName  
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
