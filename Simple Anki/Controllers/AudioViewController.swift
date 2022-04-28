//
//  AudioViewController.swift
//  Simple Anki
//
//  Created by Астемир Бозиев on 09.04.2022.
//

import UIKit

class AudioViewController: UIViewController {
    let mySegmentedControl: UISegmentedControl = {
        let segment = UISegmentedControl(items: ["Record", "Import"])
        segment.selectedSegmentIndex = 0
        return segment
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(mySegmentedControl)
        // Do any additional setup after loading the view.
        addFrames()
    }
    
    private func addFrames() {
        mySegmentedControl.frame.origin.x = (view.frame.width - mySegmentedControl.frame.width) / 2
        mySegmentedControl.frame.origin.y = 6
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
