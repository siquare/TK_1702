//
//  ViewController.swift
//  Slash
//
//  Created by Hiroaki KARASAWA on 2017/10/28.
//  Copyright © 2017年 Hiroaki KARASAWA. All rights reserved.
//

import UIKit
import AVFoundation
import AssetsLibrary
import CoreLocation
import Alamofire

class ViewController: UIViewController,AVCaptureFileOutputRecordingDelegate, CLLocationManagerDelegate  {
    let captureSession = AVCaptureSession()
    let videoDevice = AVCaptureDevice.default(for: AVMediaType.video)
    let audioDevice = AVCaptureDevice.default(for: AVMediaType.audio)
    let fileOutput = AVCaptureMovieFileOutput()
    
    var locationManager : CLLocationManager = {
        let manager = CLLocationManager()
        
        // TODO: Fix for production
        manager.distanceFilter = 1
        
        return manager
    }()
    
    var stopButton : UIButton!
    var isRecording = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let videoLayer = self.setupVideo() {
            self.view.layer.addSublayer(videoLayer)
        }
        
        self.setupButton()
        
        self.captureSession.startRunning()
        
        if CLLocationManager.authorizationStatus() != .authorizedAlways {
            locationManager.requestAlwaysAuthorization()
        }
        
        self.locationManager.startUpdatingLocation()
    }
    
    func setupVideo() -> AVCaptureVideoPreviewLayer? {
        do {
            if let videoDevice = self.videoDevice {
                let videoInput = try AVCaptureDeviceInput(device: videoDevice) as AVCaptureDeviceInput
                self.captureSession.addInput(videoInput)
            }
            if let audioDevice = self.audioDevice {
                let audioInput = try AVCaptureDeviceInput(device: audioDevice)  as AVCaptureInput
                self.captureSession.addInput(audioInput);
            }
        } catch {
            return nil
        }
        
        self.captureSession.addOutput(self.fileOutput)
        let videoLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        
        videoLayer.frame = self.view.bounds
        videoLayer.videoGravity = .resizeAspectFill
        
        return videoLayer
    }
    
    func setupButton() {
        self.stopButton = UIButton(frame: CGRect(x:0,y:0,width:120,height:50))
        self.stopButton = UIButton(frame: CGRect(x:0,y:0,width:120,height:50))
        self.stopButton.backgroundColor = .gray;
        self.stopButton.layer.masksToBounds = true
        self.stopButton.setTitle("stop", for: .normal)
        self.stopButton.layer.cornerRadius = 20.0

        self.stopButton.layer.position = CGPoint(x: self.view.bounds.width/2 + 70, y:self.view.bounds.height-50)

        self.stopButton.addTarget(self, action: #selector(onClickStopButton), for: .touchUpInside)

        self.view.addSubview(self.stopButton);

        self.isRecording = true
    }
    
    @objc func onClickStopButton(sender: UIButton){
        if self.isRecording {
            fileOutput.stopRecording()
            
            self.isRecording = false
            self.changeButtonColor(target: self.stopButton, color: UIColor.gray)
        }
        
        // This is for debugging.
        Alamofire.request("https://httpbin.org/get").response { response in
            print("Request: \(String(describing: response.request))")
            print("Response: \(String(describing: response.response) )")
            print("Error: \(String(describing: response.error))")
            
            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                print("Data: \(utf8Text)")
            }
        }
    }
    
    func changeButtonColor(target: UIButton, color: UIColor){
        target.backgroundColor = color
    }
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAtURL fileURL: NSURL!, fromConnections connections: [AnyObject]!) {
    }
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        let assetsLib = ALAssetsLibrary()
        assetsLib.writeVideoAtPath(toSavedPhotosAlbum: outputFileURL as URL!, completionBlock: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last!
        let latitude = String(format: "%+.06f", location.coordinate.latitude)
        let longitude = String(format: "%+.06f", location.coordinate.longitude)
        let df = DateFormatter()
        df.dateFormat = "yyyy/MM/dd HH:mm:ss"
        let timestamp = df.string(from: location.timestamp)
        
        print("\(timestamp) \(latitude) \(longitude)")
    }

    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        // TODO: send movie to server.
    }
}

