//
//  AppDelegate.swift
//  Muterr
//
//  Created by Chung on 15/11/2023.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet var window: NSNull!

    private let statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    private let menu = NSMenu()
    
    private var isMuted = false
    private var currentVolume = 50
    private let micImg = NSImage(named: NSImage.touchBarAudioInputTemplateName)
    private let muteMicImg = NSImage(named: NSImage.touchBarAudioInputMuteTemplateName)

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSApp.setActivationPolicy(.prohibited)

        if let button = statusBarItem.button {
            button.image = micImg
            button.action = #selector(btnClickAction)
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        menu.addItem(NSMenuItem(
            title: "Quit",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        ))
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    @objc func btnClickAction() {
        let event = NSApp.currentEvent!
        if event.type == NSEvent.EventType.rightMouseUp {
            statusBarItem.menu = menu
            statusBarItem.button?.performClick(nil)
        } else {
            toggleMute()
        }
        statusBarItem.menu = nil
    }

    func toggleMute() {
        isMuted.toggle()
        statusBarItem.button?.image = isMuted ? muteMicImg : micImg
        currentVolume = max(currentVolume, getCurrentVolume()) // Save current volume
        setVolume(volume: isMuted ? 0 : currentVolume)
    }

    func getCurrentVolume() -> Int {
        var ret = 50
        let setInputVolume = "return input volume of (get volume settings)"
        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: setInputVolume) {
            if let outputString = scriptObject.executeAndReturnError(&error).stringValue {
                ret = Int(outputString) ?? ret
            }
        }
        
        return ret <= 1 ? 0 : ret // if volume is too small, set it to zero
    }

    func setVolume(volume: Int) {
        let scriptSource = """
            set volume input volume \(volume)
        """

        if let script = NSAppleScript(source: scriptSource) {
            var error: NSDictionary?
            script.executeAndReturnError(&error)
        }
    }
}

