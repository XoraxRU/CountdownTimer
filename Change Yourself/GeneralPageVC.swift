//
//  GeneralPageVC.swift
//  Change Yourself
//
//  Created by Vladimir Erdman on 13/09/2018.
//  Copyright © 2018 Coral Club. All rights reserved.
//

import UIKit


// creating structure of an array
struct WebsiteDescription: Decodable {
    private enum CodingKeys : String, CodingKey {
        case seasonDeadline = "season_deadline"
        case season_start = "season_start"
    }
    let seasonDeadline: ControlDesk
    let season_start: ControlDesk
}
struct ControlDesk: Decodable {
    private enum CodingKeys : String, CodingKey {
        case id = "ID"
        case name = "NAME"
        case code = "CODE"
        case value = "VALUE"
        case iblockId = "IBLOCK_ID"
    }
    let id : String
    let name : String
    let code : String
    let value : String
    let iblockId : String
    
    init(json: [String: Any]) {
        id = json["ID"] as? String ?? ""//as? Int ?? -1
        name = json["NAME"] as? String ?? ""
        code = json["CODE"] as? String ?? ""
        value = json["VALUE"] as? String ?? ""
        iblockId = json["IBLOCK_ID"] as? String ?? ""//as? Int ?? -1
    }
}



class GeneralPageVC: UIViewController {
    
    // url to JSON
    let videoIBJson = "https://xorax.ru/changeyourself/mobileapp/general.php"
    
    // timer Block
    @IBOutlet weak var countdownTimer: UIView!
    @IBOutlet weak var timerDay: UIView!
    @IBOutlet weak var timerHour: UIView!
    @IBOutlet weak var timerMinute: UIView!
    @IBOutlet weak var timerSecond: UIView!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var minuteLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    
    // formating date value
    let formatter = DateFormatter()
    let userCalendar = Calendar.current
    var seasonStartTime = "" // for value from JSON
    var seasonEndTime = "" // for value from JSON
    var currentTime : Date? = nil
    var startTime : Date? = nil
    var endTime : Date? = nil
    // UTC to Date
    var utcToCurrentTimeDate : Date? = nil
    var utcToEndTimeDate : Date? = nil
    var utcToStartTimeDate : Date? = nil
    // percentage
    var anHour = Float()
    var aMinute = Float()
    var aSecond = Float()
    var percentDaysPassed = Double() // for percentage
    var percentHoursPassed = Float() // for percentage of Hours
    var percentMinutesPassed = Float() // for percentage of Minutes
    var percentSecondsPassed = Float() // for percentage of Seconds
    var percentOnLoad = Timer()
    var percentUpdate = Timer()
    // layers for progress timer
    //var timerD: CALayer { return timerDay.layer }
    fileprivate let defaultDayLayer = CAShapeLayer()
    fileprivate let shapeDayLayer = CAShapeLayer()
    //var timerH: CALayer { return timerHour.layer }
    fileprivate let defaultHourLayer = CAShapeLayer()
    fileprivate let shapeHourLayer = CAShapeLayer()
    //var timerM: CALayer { return timerMinute.layer }
    fileprivate let defaultMinuteLayer = CAShapeLayer()
    fileprivate let shapeMinuteLayer = CAShapeLayer()
    //var timerS: CALayer { return timerSecond.layer }
    fileprivate let defaultSecondLayer = CAShapeLayer()
    fileprivate let shapeSecondLayer = CAShapeLayer()
    // update value
    var timer = Timer()
 
    // Total block
    @IBOutlet weak var totalBlock: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Removing bottom border from navigation bar
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        // styling blocks
        countdownTimer.layer.cornerRadius = 10
        // Data
        getRequest() // getting JSON
        seasonTimer() // timer starter
        progressLayer() // progress bar for timer
    }
  
    
    // Receive JSON
    private func getRequest() {
        guard let url = URL(string: videoIBJson) else { return }
        let task = URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            if error != nil {
                print("Get error = \(String(describing: error))")
                return
            } else {
                /*
                 guard let response = response as? HTTPURLResponse,
                 (200...299).contains(response.statusCode) else {
                 print ("Server error")
                 return
                 }
                 */
                guard let data = data else { return }
                do {
                    /*// show JSON
                    let jsonResult = try JSONSerialization.jsonObject(with: data, options: [])
                    print(jsonResult)
                    */// decode JSON
                    let websiteDescription = try JSONDecoder().decode(WebsiteDescription.self, from: data)
                    //print("RESULT: ", websiteDescription.season_start, websiteDescription.seasonDeadline)
                    self.seasonStartTime = websiteDescription.season_start.value
                    self.seasonEndTime = websiteDescription.seasonDeadline.value
                }
                catch let parsingError {
                    print("ERROR! GET JSON processing failed: ", parsingError)
                }
            }
        }
        task.resume()
    }
    
    
    
    func seasonTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(printTime), userInfo: nil, repeats: true)
        guard seasonEndTime.isEmpty else { return print("seasonTimer error because of empty seasonEndTime")}
        do {
            print("seasonEndTime has a value")
            timer.fire()
        }
            
    }
    
    
    
    
    
    @objc private func printTime() {
        if seasonEndTime != "" {
            // Adding "Z"
            let seasonEndTimeFull = seasonEndTime + String("Z")
            let seasonStartTimeFull = seasonStartTime + String("Z")//String("01.08.2018 00:00:00Z")
            // Input
            formatter.dateFormat = "dd.MM.yyyy HH:mm:ssZ"
            formatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
            // Getting UTC
            currentTime = Date()
            startTime = formatter.date(from: seasonStartTimeFull)
            endTime = formatter.date(from: seasonEndTimeFull)
            // Output
            formatter.dateFormat = "dd.MM.yyyy HH:mm:ssZ"
            formatter.timeZone = TimeZone.current
            // converting UTC (to String)
            let utcToCurrentTimeString = formatter.string(from: currentTime!) //Convert date to string
            let utcToStartTimeString = formatter.string(from: startTime!)
            let utcToEndTimeString = formatter.string(from: endTime!) //Convert date to string
            // converting UTC (to Date)
            utcToCurrentTimeDate = formatter.date(from: utcToCurrentTimeString)
            utcToEndTimeDate = formatter.date(from: utcToEndTimeString)
            utcToStartTimeDate = formatter.date(from: utcToStartTimeString)
            // getting difference between current and deadline
            let timeDifference = userCalendar.dateComponents([.day, .hour, .minute, .second], from: utcToCurrentTimeDate!, to: utcToEndTimeDate!)
            let dayLb: Int = timeDifference.day!
            let hourLb: Int = timeDifference.hour!
            let minuteLb: Int = timeDifference.minute!
            let secondLb: Int = timeDifference.second!
            dayLabel.text = String(format: "%02i", dayLb)
            minuteLabel.text = String(format: "%02i", minuteLb)
            hourLabel.text = String(format: "%02i", hourLb)
            secondLabel.text = String(format: "%02i", secondLb)
            // getting percentage
            anHour = Float(hourLb)
            aMinute = Float(minuteLb)
            aSecond = Float(secondLb)
            percentHoursPassed = round(10 * (24 - anHour) / 24) / 10 // a day passes
            percentMinutesPassed = (10 * (60 - aMinute) / 60) / 10 // an hour passes
            percentSecondsPassed = (10 * (60 - aSecond) / 60) / 10 // a minute passes
            // a season passes
            let duration = DateInterval(start: utcToStartTimeDate!, end: utcToEndTimeDate!).duration
            let complete = DateInterval(start: utcToStartTimeDate!, end: utcToCurrentTimeDate!).duration
            let percentComplete = complete / duration
            percentDaysPassed = Double(round(10 * percentComplete) / 10)
        } else {
            dayLabel.text = String("00")
            hourLabel.text = String("00")
            minuteLabel.text = String("00")
            secondLabel.text = String("00")
        }
    }
    
    
    
    
    
    
    func progressLayer() {
        //let center = timerDay.center
        let circularPath = UIBezierPath(arcCenter: CGPoint.init(x: 35, y: 36), radius: 30, startAngle: -CGFloat.pi / 2, endAngle: 1.48 * CGFloat.pi, clockwise: true)
        
        // Day circule
        defaultDayLayer.path = circularPath.cgPath
        defaultDayLayer.strokeColor = UIColor.orange.cgColor // default line
        defaultDayLayer.lineWidth = 5 // default line
        defaultDayLayer.fillColor = UIColor.clear.cgColor
        //defaultDayLayer.lineCap = kCALineCapRound // change strict line to round
        defaultDayLayer.lineCap = kCALineCapRound
        timerDay.layer.addSublayer(defaultDayLayer)
        shapeDayLayer.path = circularPath.cgPath
        shapeDayLayer.strokeColor = UIColor.white.cgColor // load line
        shapeDayLayer.lineWidth = 4
        shapeDayLayer.fillColor = UIColor.clear.cgColor
        shapeDayLayer.lineCap = kCALineCapRound // change strict line to round
        shapeDayLayer.strokeEnd = 1 // Full
        timerDay.layer.addSublayer(shapeDayLayer)
        // An hour circule
        defaultHourLayer.path = circularPath.cgPath
        defaultHourLayer.strokeColor = UIColor.orange.cgColor // default line
        defaultHourLayer.lineWidth = 5 // default line
        defaultHourLayer.fillColor = UIColor.clear.cgColor
        defaultHourLayer.lineCap = kCALineCapRound // change strict line to round
        timerHour.layer.addSublayer(defaultHourLayer)
        shapeHourLayer.path = circularPath.cgPath
        shapeHourLayer.strokeColor = UIColor.white.cgColor // load line
        shapeHourLayer.lineWidth = 4
        shapeHourLayer.fillColor = UIColor.clear.cgColor
        shapeHourLayer.lineCap = kCALineCapRound // change strict line to round
        shapeHourLayer.strokeEnd = 1 // Full
        timerHour.layer.addSublayer(shapeHourLayer)
        // A minute circule
        defaultMinuteLayer.path = circularPath.cgPath
        defaultMinuteLayer.strokeColor = UIColor.orange.cgColor // default line
        defaultMinuteLayer.lineWidth = 5 // default line
        defaultMinuteLayer.fillColor = UIColor.clear.cgColor
        defaultMinuteLayer.lineCap = kCALineCapRound // change strict line to round
        timerMinute.layer.addSublayer(defaultMinuteLayer)
        shapeMinuteLayer.path = circularPath.cgPath
        shapeMinuteLayer.strokeColor = UIColor.white.cgColor // load line
        shapeMinuteLayer.lineWidth = 4
        shapeMinuteLayer.fillColor = UIColor.clear.cgColor
        shapeMinuteLayer.lineCap = kCALineCapRound // change strict line to round
        shapeMinuteLayer.strokeEnd = 0 // Full
        timerMinute.layer.addSublayer(shapeMinuteLayer)
        // A second circule
        defaultSecondLayer.path = circularPath.cgPath
        defaultSecondLayer.strokeColor = UIColor.orange.cgColor // default line
        defaultSecondLayer.lineWidth = 5 // default line
        defaultSecondLayer.fillColor = UIColor.clear.cgColor
        defaultSecondLayer.lineCap = kCALineCapRound // change strict line to round
        timerSecond.layer.addSublayer(defaultSecondLayer)
        shapeSecondLayer.path = circularPath.cgPath
        shapeSecondLayer.strokeColor = UIColor.white.cgColor // load line
        shapeSecondLayer.lineWidth = 4
        shapeSecondLayer.fillColor = UIColor.clear.cgColor
        shapeSecondLayer.lineCap = kCALineCapRound // change strict line to round
        shapeSecondLayer.strokeEnd = 0 // Full
        timerSecond.layer.addSublayer(shapeSecondLayer)
        // Start animation
        progressLoad()
    }
    
    
    
    @objc private func progressLoad() {
        // Day
        let dayAnimation = CABasicAnimation(keyPath: "strokeEnd")
        dayAnimation.fromValue = 0
        dayAnimation.toValue = percentDaysPassed
        dayAnimation.duration = 1
        dayAnimation.fillMode = kCAFillModeForwards
        dayAnimation.isRemovedOnCompletion = false
        shapeDayLayer.add(dayAnimation, forKey: "urSoBasic")
        // Hour
        let hourAnimation = CABasicAnimation(keyPath: "strokeEnd")
        hourAnimation.fromValue = 0
        hourAnimation.toValue = percentHoursPassed
        hourAnimation.duration = 0.8
        hourAnimation.fillMode = kCAFillModeForwards
        hourAnimation.isRemovedOnCompletion = false
        shapeHourLayer.add(hourAnimation, forKey: "urSoBasic")
        // Minute
        let minuteAnimation = CABasicAnimation(keyPath: "strokeEnd")
        minuteAnimation.fromValue = 0
        minuteAnimation.toValue = percentMinutesPassed
        minuteAnimation.duration = 0.6
        minuteAnimation.fillMode = kCAFillModeForwards
        minuteAnimation.isRemovedOnCompletion = false
        shapeMinuteLayer.add(minuteAnimation, forKey: "urSoBasic")
        // Second
        let secondAnimation = CABasicAnimation(keyPath: "strokeEnd")
        secondAnimation.fromValue = 0
        secondAnimation.toValue = percentSecondsPassed
        secondAnimation.duration = 0.4
        secondAnimation.fillMode = kCAFillModeForwards
        secondAnimation.isRemovedOnCompletion = false
        shapeSecondLayer.add(secondAnimation, forKey: "urSoBasic")
        
        self.percentUpdate.invalidate()
        self.percentUpdate = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (percentUpdate) in
            if self.aSecond == 0.0 {
                self.progressMinuteUpdate()
            }
            if self.aMinute == 0.0 {
                self.progressHourUpdate()
            }
            if self.anHour == 0.0 {
                self.progressDayUpdate()
            }
            self.progressSecondUpdate()
        })
        
        self.percentOnLoad.invalidate()
        self.percentOnLoad = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { (percentOnLoad) in
            self.progressDayUpdate()
            self.progressHourUpdate()
            self.progressMinuteUpdate()
            self.progressSecondUpdate()
        })
        
    }
    
    
    
    @objc private func progressDayUpdate() {
        let dayAnimation = CABasicAnimation(keyPath: "strokeEnd")
        dayAnimation.fromValue = percentDaysPassed
        dayAnimation.toValue = percentDaysPassed
        dayAnimation.duration = 1
        dayAnimation.fillMode = kCAFillModeForwards
        dayAnimation.isRemovedOnCompletion = false
        shapeDayLayer.add(dayAnimation, forKey: "urSoBasic")
    }
    @objc private func progressHourUpdate() {
        let hourAnimation = CABasicAnimation(keyPath: "strokeEnd")
        hourAnimation.fromValue = percentHoursPassed
        hourAnimation.toValue = percentHoursPassed
        hourAnimation.duration = 1
        hourAnimation.fillMode = kCAFillModeForwards
        hourAnimation.isRemovedOnCompletion = false
        shapeHourLayer.add(hourAnimation, forKey: "urSoBasic")
    }
    @objc private func progressMinuteUpdate() {
        let minuteAnimation = CABasicAnimation(keyPath: "strokeEnd")
        minuteAnimation.fromValue = percentMinutesPassed
        minuteAnimation.toValue = percentMinutesPassed
        minuteAnimation.duration = 1
        minuteAnimation.fillMode = kCAFillModeForwards
        minuteAnimation.isRemovedOnCompletion = false
        shapeMinuteLayer.add(minuteAnimation, forKey: "urSoBasic")
    }
    @objc private func progressSecondUpdate() {
        let secondAnimation = CABasicAnimation(keyPath: "strokeEnd")
        secondAnimation.fromValue = percentSecondsPassed
        secondAnimation.toValue = percentSecondsPassed
        secondAnimation.duration = 1
        secondAnimation.fillMode = kCAFillModeForwards
        secondAnimation.isRemovedOnCompletion = false
        shapeSecondLayer.add(secondAnimation, forKey: "urSoBasic")
    }
    


}
