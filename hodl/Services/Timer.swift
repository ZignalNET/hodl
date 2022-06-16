//
//  Timer.swift
//  Part of Hodl.
//
//  Created by Emmanuel Adigun on 2022/06/08.
//  Copyright © 2022 Zignal Systems. All rights reserved.
//

import Foundation

typealias TimerCallBack = (_ timer: Timer ) -> Void
class Timer {
    private enum State {
        case suspended
        case resumed
    }
    
    let timeInterval: Int
    let timerID: String
    
    var callback: TimerCallBack?
    
    required init(_ timerID: String = "" , _ timeInterval: Int = 5, _ callback: TimerCallBack? ) {
        self.timeInterval = timeInterval
        self.timerID = timerID
        self.callback = callback
    }
    
    private lazy var timer: DispatchSourceTimer = {
        let t = DispatchSource.makeTimerSource()
        t.schedule(deadline: .now() /*+ self.timeInterval*/, repeating: .seconds(self.timeInterval) , leeway: .seconds(0))
        t.setEventHandler(handler: { [weak self] in
            if let this = self, let callback = this.callback {
                callback(this)
            }
        })
        return t
    }()
    
    
    
    private var state: State = .suspended
    
    deinit { stop() }
    
    func isRunning() -> Bool { return state == .resumed }
    
    func stop() {
        timer.setEventHandler {}
        timer.cancel()
        /*
         If the timer is suspended, calling cancel without resuming
         triggers a crash. This is documented here https://forums.developer.apple.com/thread/15902
         */
        resume()
    }
    
    func resume() {
        if state == .resumed { return }
        state = .resumed
        timer.resume()
    }
    
    func suspend() {
        if state == .suspended { return }
        state = .suspended
        timer.suspend()
    }
}
