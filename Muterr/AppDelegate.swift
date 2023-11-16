//
//  AppDelegate.swift
//  Muterr
//
//  Created by Chung on 15/11/2023.
//

import Cocoa
import LaunchAtLogin

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet var window: NSNull!

    private let statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    private let menu = NSMenu()
    private let lalCheckbox = NSMenuItem(
        title: "Launch at Login",
        action: #selector(toggleLaunchAtLogin),
        keyEquivalent: ""
    )
    
    private var isMuted = false
    private var currentVolume = 50
    private let micImg = NSImage(named: NSImage.touchBarAudioInputTemplateName)
    private let muteMicImg = NSImage(named: NSImage.touchBarAudioInputMuteTemplateName)

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSApp.setActivationPolicy(.prohibited)
        prepareMenu()
        if getCurrentVolume() == 0 {
            isMuted = true
            statusBarItem.button?.image = muteMicImg
        }
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
            statusBarItem.menu = nil
        } else {
            toggleMute()
        }
    }

    @objc func toggleLaunchAtLogin() {
        let lal = !LaunchAtLogin.isEnabled
        lalCheckbox.state = lal ? .on : .off
        LaunchAtLogin.isEnabled = lal
    }

    func prepareMenu() {
        if let button = statusBarItem.button {
            button.image = micImg
            button.action = #selector(btnClickAction)
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        lalCheckbox.state = LaunchAtLogin.isEnabled ? .on : .off
        menu.addItem(lalCheckbox)
        menu.addItem(NSMenuItem.separator())

        menu.addItem(NSMenuItem(
            title: "Quit",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        ))
    }
    
    func toggleMute() {
        isMuted.toggle()
        if (isMuted) {
            statusBarItem.button?.image = muteMicImg
            currentVolume = getCurrentVolume()
            setVolume(0)
        } else {
            statusBarItem.button?.image = micImg
            setVolume(currentVolume)
        }
    }

    func getCurrentVolume() -> Int {
        var ret = 50 // this should be configurable
        let setInputVolume = "return input volume of (get volume settings)"
        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: setInputVolume) {
            if let outputString = scriptObject.executeAndReturnError(&error).stringValue {
                ret = Int(outputString)!
            }
        }

        return ret <= 5 ? 0 : ret // if volume is too small, set it to zero
    }

    func setVolume(_ volume: Int) {
        let scriptSource = """
            set volume input volume \(volume)
        """

        if let script = NSAppleScript(source: scriptSource) {
            var error: NSDictionary?
            script.executeAndReturnError(&error)
        }
    }
}
