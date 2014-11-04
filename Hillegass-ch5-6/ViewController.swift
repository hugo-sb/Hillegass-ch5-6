//
//  ViewController.swift
//  Hillegass-ch5-6
//
//  Created by 野村修 on 2014/10/29.
//  Copyright (c) 2014年 ofellabuta. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSSpeechSynthesizerDelegate {

    @IBOutlet weak var textField: NSTextField!
    @IBOutlet weak var stopButton: NSButton!
    @IBOutlet weak var speakButton: NSButton!
    @IBOutlet weak var tableView: NSTableView!
    
    let speechSynth = NSSpeechSynthesizer()
    let voiceList = NSSpeechSynthesizer.availableVoices()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        speechSynth.delegate = self

        let defaultVoice = NSSpeechSynthesizer.defaultVoice()
        for i in (0...voiceList!.count)
        {
            if (voiceList![i] as NSString) == defaultVoice
            {
                tableView.selectRowIndexes(NSIndexSet(index: i), byExtendingSelection: false)
                tableView.scrollRowToVisible(i)
                break
            }
        }
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func sayIt(sender: AnyObject) {
        var str = textField.stringValue
        if countElements(str) > 0
        {
            speechSynth.startSpeakingString(str)
            NSLog("Have started to say: \(str)")
            stopButton.enabled = true
            speakButton.enabled = false
            tableView.enabled = false
        }
        else
        {
            NSLog("string from %@ is of zero-length", textField)
        }
    }

    @IBAction func stopIt(sender: AnyObject) {
        speechSynth.stopSpeaking()
        NSLog("stopping")
    }
    
    func speechSynthesizer(sender: NSSpeechSynthesizer, didFinishSpeaking finishedSpeaking: Bool)
    {
        stopButton.enabled = false
        speakButton.enabled = true
        tableView.enabled = true
    }
    
    func numberOfRowsInTableView(aTableView: NSTableView) -> Int
    {
        return voiceList!.count
    }
    
    func tableView(aTableView: NSTableView,
        objectValueForTableColumn aTableColumn: NSTableColumn?,
        row rowIndex: Int) -> AnyObject?
    {
        let v = voiceList![rowIndex] as NSString
        let dict = NSSpeechSynthesizer.attributesForVoice(v)
        return dict![NSVoiceName]
    }
    
    func tableViewSelectionDidChange(aNotification: NSNotification)
    {
        let row = tableView.selectedRow
        if row >= 0
        {
            let selectedVoice = voiceList![row] as String
            speechSynth.setVoice(selectedVoice)
            NSLog("New voice: \(selectedVoice)")
        }
    }
}

