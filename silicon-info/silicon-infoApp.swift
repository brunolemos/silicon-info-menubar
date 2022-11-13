//
//  SiliconInfoApp.swift
//  silicon-info
//
//  Created by Billy Castelli on 11/22/20.
//

import SwiftUI

struct RunningApplication {
    let appName: String
    let architecture: String
    let appImage: NSImage
    let processorIcon: NSImage
    let opacity: Double
}

@main
struct SiliconInfoApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    // Set notification for active applications
    override init(){
        super.init()
        NSWorkspace.shared.notificationCenter.addObserver(self,
            selector: #selector(iconSwitcher(notification:)),
            name: NSWorkspace.didActivateApplicationNotification,
            object:nil)

    }
    var application: NSApplication = NSApplication.shared
    var statusBarItem: NSStatusItem?
    let menu = NSMenu()
    
    // Run function when application first opens
    func applicationDidFinishLaunching(_ notification: Notification) {
        menu.delegate = self;
        
        // Grab application information from frontmost application
        let app = getApplicationInfo(application: NSWorkspace.shared.frontmostApplication)
        
        // Set view
        let contentView = ContentView(appName: app.appName, architecture: app.architecture, appIcon: app.appImage)
        let menuItem = NSMenuItem()
        let view = NSHostingView(rootView: contentView)
        view.frame = NSRect(x: 0, y: 0, width: 200, height: 100)
        menuItem.view = view
        menu.addItem(menuItem)
        menu.addItem(NSMenuItem(title: "Quit Silicon Info", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        // Set initial app icon
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        let itemImage = app.processorIcon;
        itemImage.isTemplate = true
        statusBarItem?.button?.image = itemImage
        statusBarItem?.menu = menu
        statusBarItem?.button?.alphaValue = app.opacity
    }
    
    
    // Run function when menu bar icon is clicked
    func menuWillOpen(_ menu: NSMenu) {
        // Grab application information from frontmost application
        let app = getApplicationInfo(application: NSWorkspace.shared.frontmostApplication)
        
        // Set view
        let contentView = ContentView(appName: app.appName, architecture: app.architecture, appIcon: app.appImage)
        let menuItem = NSMenuItem()
        let view = NSHostingView(rootView: contentView)
        view.frame = NSRect(x: 0, y: 0, width: 200, height: 100)
        menuItem.view = view
        menu.removeAllItems()
        menu.addItem(menuItem)
        menu.addItem(NSMenuItem(title: "Quit Silicon Info", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        // Update icon
        let itemImage = app.processorIcon;
        itemImage.isTemplate = true
        statusBarItem?.button?.image = itemImage
    }
    
    // Run function when a new application is sent to front
    @objc func iconSwitcher(notification: NSNotification) {
        guard let notification = notification.userInfo else {
            return;
        }
        guard let runningApplication = notification["NSWorkspaceApplicationKey"] else {
            return
        }
        let app = getApplicationInfo(application: runningApplication as? NSRunningApplication)
        let itemImage = app.processorIcon;
        itemImage.isTemplate = true
        statusBarItem?.button?.image = itemImage
    }
    
    func getApplicationInfo(application: NSRunningApplication?) ->RunningApplication{
        // Check if application is nil, passed in item is not guaranteed to be an object
        guard let runningApp = application else {
            return RunningApplication(appName: "Unknown", architecture: "Cannot identify frontmost app", appImage: NSImage(named: "processor-icon-empty") ?? NSImage(), processorIcon: NSImage(named: "processor-icon-empty") ?? NSImage(), opacity: 1)
        }
        // After checking for nil, we can refer to runningApp, guarenteed to be NSRunningApplication
        let frontAppName = runningApp.localizedName ?? String()
        let frontAppImage = runningApp.icon ?? NSImage()
        let architectureInt = runningApp.executableArchitecture


        var architecture = ""
        var processorIcon = NSImage()
        var opacity = 1.0
        switch architectureInt {
        case NSBundleExecutableArchitectureARM64:
            architecture = "arm64 • Apple Silicon"
            processorIcon = NSImage(named: "processor-icon") ?? NSImage()
            opacity = 0.25
        case NSBundleExecutableArchitectureI386:
            architecture = "x86 • Intel 32-bit"
            processorIcon = NSImage(named: "processor-icon-empty") ?? NSImage()
        case NSBundleExecutableArchitectureX86_64:
            architecture = "x86-64 • Intel 64-bit"
            processorIcon = NSImage(named: "processor-icon-empty") ?? NSImage()
        case NSBundleExecutableArchitecturePPC:
            architecture = "ppc32 • PowerPC 32-bit"
            processorIcon = NSImage(named: "processor-icon-empty") ?? NSImage()
        case NSBundleExecutableArchitecturePPC64:
            architecture = "ppc64 • PowerPC 64-bit"
            processorIcon = NSImage(named: "processor-icon-empty") ?? NSImage()
        default:
            architecture = "Unknown • Unknown"
            processorIcon = NSImage(named: "processor-icon-empty") ?? NSImage()
        }
        return RunningApplication(appName: frontAppName, architecture: architecture, appImage: frontAppImage, processorIcon: processorIcon, opacity: opacity)
    }
}
