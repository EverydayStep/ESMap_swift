//
//  ESMap.swift
//  ESMap_swift
//
//  Created by codeLocker on 2020/5/26.
//  Copyright © 2020 codeLocker. All rights reserved.
//

import UIKit
import AMapLocationKit
import AMapFoundationKit

public class ESMap: NSObject {
    
    static let map: ESMap = ESMap()
    
    /// 定位
    fileprivate lazy var locationManager = AMapLocationManager()
    
    /// 持续定位结果返回
    public var didUpdateLocation: ((CLLocation?, AMapLocationReGeocode?) -> ())?
    /// 定位失败
    public var locationFail: ((Error?) -> ())?
    /// 定位权限变化
    public var authorizationStatusChange: ((CLAuthorizationStatus) -> ())?
    /// 定位权限状态
    public var authorizationStatus: CLAuthorizationStatus {
        get {
            return CLLocationManager.authorizationStatus()
        }
    }
    /// 是否可以定位即已经有定位权限
    public var canLocation: Bool {
        get {
            return !(self.authorizationStatus != .notDetermined || self.authorizationStatus != .restricted)
        }
    }
    
    /// 注册高德服务
    /// - Parameter key: key
    public func register(key: String) {
        AMapServices.shared()?.apiKey = key
        AMapServices.shared()?.enableHTTPS = true
    }
    
    /// 申请Awalys权限
    public func requestAlwaysAuthorization() {
        CLLocationManager.init().requestAlwaysAuthorization()
    }
    
    /// 申请WhenInUse权限
    public func requestWhenInUseAuthorization() {
        CLLocationManager.init().requestWhenInUseAuthorization()
        
    }
    
    /// 单次定位
    /// - Parameters:
    ///   - accuracy: 定位精度
    ///   - regeocode: 是否地理反编码
    ///   - locationTimeout: 定位超时时间
    ///   - regeocodeTimeout: 地理反编码超时时间
    ///   - success: 成功
    ///   - fail: 失败
    public func onceLocation(accuracy: CLLocationAccuracy = kCLLocationAccuracyHundredMeters,
                             regeocode: Bool = true,
                             locationTimeout: Int = 10,
                             regeocodeTimeout: Int = 10,
                             success: @escaping (CLLocation?, AMapLocationReGeocode?) -> Void,
                             fail: @escaping (Error?) -> Void) {
        if !self.canLocation {
            fail(nil)
        }
        self.locationManager.desiredAccuracy = accuracy
        self.locationManager.locationTimeout = locationTimeout
        self.locationManager.reGeocodeTimeout = regeocodeTimeout
        self.locationManager.requestLocation(withReGeocode: regeocode) { (location, regeocode, error) in
            if let _ = error {
                fail(error)
            } else {
                success(location, regeocode)
            }
        }
    }
    
    /// 持续定位
    /// - Parameters:
    ///   - distanceFilter: 定位更新偏差值
    ///   - regeocode: 是否地理反编码
    ///   - isBackground: 是否支持后台定位
    public func sustainLocation(distanceFilter: CLLocationDistance = 200, regeocode: Bool = true, isBackground: Bool = false) {
        if !self.canLocation {
            return
        }
        self.locationManager.delegate = self
        self.locationManager.distanceFilter = distanceFilter
        self.locationManager.locatingWithReGeocode = regeocode
        self.locationManager.allowsBackgroundLocationUpdates = isBackground
        self.locationManager.startUpdatingLocation()
    }
    
    /// 停止定位
    public func stopLocation() {
        self.locationManager.stopUpdatingLocation()
    }
}

extension ESMap: AMapLocationManagerDelegate {
    public func amapLocationManager(_ manager: AMapLocationManager!, didUpdate location: CLLocation!, reGeocode: AMapLocationReGeocode!) {
        self.didUpdateLocation?(location, reGeocode)
    }
    
    public func amapLocationManager(_ manager: AMapLocationManager!, didFailWithError error: Error!) {
        self.locationFail?(error)
    }
    
    public func amapLocationManager(_ manager: AMapLocationManager!, didChange status: CLAuthorizationStatus) {
        self.authorizationStatusChange?(status)
    }
}
