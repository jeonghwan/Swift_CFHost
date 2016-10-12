//
//  ViewController.swift
//  Swift_CFHostDemo
//
//  Created by ImJeonghwan on 10/13/16.
//  Copyright © 2016 ImJeonghwan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var hostnameTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var resultTextField: UITextField!
    
    @IBAction func getAddressesForHostname(sender: AnyObject) {
        var addresses:[String] = []
        let cfStringRef = CFStringCreateWithCString(kCFAllocatorDefault, hostnameTextField.text! , CFStringEncoding(NSASCIIStringEncoding))
        
        let unmanagedCFHostRef = CFHostCreateWithName(kCFAllocatorDefault, cfStringRef)
        let cfHostRef = unmanagedCFHostRef.takeUnretainedValue() as CFHostRef
        let result = CFHostStartInfoResolution(cfHostRef, CFHostInfoType.Addresses, nil)
        if result != false {
            let nsArray = CFHostGetAddressing(cfHostRef, nil)!.takeUnretainedValue() as NSArray
            for address:AnyObject in nsArray {
                let dataObject = address as! NSData
                var sockaddrObject = sockaddr(sa_len: __uint8_t(0), sa_family: sa_family_t(0), sa_data: (0,0,0,0,0,0,0,0,0,0,0,0,0,0))
                dataObject.getBytes(&sockaddrObject, length:Int(sizeof(sockaddr)))
                
                if sockaddrObject.sa_family == sa_family_t(AF_INET) {
                    let ip4Address = withUnsafePointer(&sockaddrObject) { pointer -> String in
                        let sockaddr4 = UnsafePointer<sockaddr_in>(pointer)
                        var ipString:[CChar] = [CChar](count:Int(INET_ADDRSTRLEN), repeatedValue:0)
                        var quad:in_addr = sockaddr4.memory.sin_addr
                        inet_ntop(Int32(AF_INET), &quad, &ipString, socklen_t(ipString.count))
                        return String.fromCString(ipString)!
                    }
                    addresses.append(ip4Address)
                } else if sockaddrObject.sa_family == sa_family_t(AF_INET6) {
                    let ip6Address = withUnsafePointer(&sockaddrObject) {
                        pointer -> String in
                        let sockaddr6 = UnsafePointer<sockaddr_in6>(pointer)
                        var ipString:[CChar] = [CChar](count:Int(INET6_ADDRSTRLEN), repeatedValue:0)
                        var quad:in6_addr = sockaddr6.memory.sin6_addr
                        inet_ntop(Int32(AF_INET6), &quad, &ipString, socklen_t(ipString.count))
                        return String.fromCString(ipString)!
                    }
                    addresses.append(ip6Address)
                }
                
            }
            
            var currentResults = ""
            for displayAddress:String in addresses {
                if currentResults.characters.count > 0 {
                    currentResults += "\n"
                }
                currentResults += displayAddress
            }
            
            resultTextField.text = currentResults
        }
    }
    
    @IBAction func getHostnamesForAddress(sender: AnyObject) {
        var names:[String] = []
        
        var hints = addrinfo(ai_flags: 0, ai_family: AF_UNSPEC, ai_socktype: SOCK_STREAM, ai_protocol: 0, ai_addrlen: 0, ai_canonname: nil, ai_addr: nil, ai_next: nil)
        
        var addrResult = UnsafeMutablePointer<addrinfo>(nil)
        
        let addrCString = addressTextField.text!.cStringUsingEncoding(NSASCIIStringEncoding)
        
        let resultCode = getaddrinfo(addrCString!, nil, &hints, &addrResult )
        
        if 0 == resultCode {
            
            let nsData = CFDataCreate(kCFAllocatorDefault, UnsafePointer<UInt8>(addrResult.memory.ai_addr), CFIndex(addrResult.memory.ai_addrlen)) as NSData
            
            let unmanagedCFHostRef = CFHostCreateWithAddress( kCFAllocatorDefault, nsData)
            
            let cfHostRef = unmanagedCFHostRef.takeUnretainedValue() as CFHostRef
            
            let resultBool = CFHostStartInfoResolution(cfHostRef, CFHostInfoType.Names, nil)
            
            if resultBool != false {
                let nsArray = CFHostGetNames(cfHostRef, nil)!.takeUnretainedValue() as NSArray
                for hostname:AnyObject in nsArray {
                    if let hostnameString=hostname as? String {
                        names.append(hostnameString)
                    }
                }
            }
            
            var currentResults = ""
            for displayHostname:String in names {
                if currentResults.characters.count > 0 {
                    currentResults += "\n"
                }
                currentResults += displayHostname
            }
            
            resultTextField.text = currentResults
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
        
        

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

