//
//  JLSoundPlayer.swift
//  Talk
//
//  Created by 史丹青 on 1/29/16.
//  Copyright © 2016 Teambition. All rights reserved.
//

import UIKit
import AVFoundation

private let sharedInstance = JLSoundPlayer()

class JLSoundPlayer: NSObject {
    
    var soundURL = NSURL()
    var soundID: SystemSoundID = 0
    var mainBundle: CFBundleRef = CFBundleGetMainBundle()
    
    class var sharedSoundPlayer: JLSoundPlayer {
        return sharedInstance
    }
    
    func setSoundWithName(name:String, andExtension soundExtension:String) {
        soundURL = NSBundle.mainBundle().URLForResource(name, withExtension: soundExtension)!
        AudioServicesCreateSystemSoundID(soundURL, &soundID);
    }
    
    func playSoundWithName(name:String, andExtension soundExtension:String) {
        soundURL = NSBundle.mainBundle().URLForResource(name, withExtension: soundExtension)!
        AudioServicesCreateSystemSoundID(soundURL, &soundID);
        AudioServicesPlaySystemSound(soundID);
    }
    
    func playSound() {
        AudioServicesPlaySystemSound(soundID);
    }
    
    func stopSound() {
//        if audioPlayer.playing {
//            audioPlayer.stop()
//        }
    }
    
}
