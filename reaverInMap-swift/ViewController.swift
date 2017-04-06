//
//  ViewController.swift
//  reaverInMap-swift
//
//  Created by 翁乐 on 16/12/2016.
//  Copyright © 2016 Autonavi. All rights reserved.
//

import UIKit

class ViewController: UIViewController, MAMapViewDelegate, AMap3DObjectOverlayRendererDelegate, UIGestureRecognizerDelegate {
    
    var _selfMapView: MAMapView!

    var mapView: MAMapView! {
        get {
            if _selfMapView == nil {
                _selfMapView = MAMapView(frame: self.view.bounds)
                _selfMapView.centerCoordinate = CLLocationCoordinate2DMake(39.991647, 116.475237)
                _selfMapView.zoomLevel = 15.0
                _selfMapView.isAllowDecreaseFrame = false
                _selfMapView.isShowsBuildings = false
                _selfMapView.isShowsLabels = false
                _selfMapView.mapType = .navi
            }
            return _selfMapView
        }
    }
    var airPlaneOverlay: AMap3DObjectOverlay!
    var carOverlay: AMap3DObjectOverlay!
    var monsterOverlay: AMap3DObjectOverlay!
    var house1: AMap3DObjectOverlay!
    var house2: AMap3DObjectOverlay!

    required init?(coder aDecoder: NSCoder) {
//        self._record = CLLocationCoordinate2DMake(0, 0)
        super.init(coder: aDecoder)
    }
    
//    func currentOverlayCenterCoordinate(coordinate: CLLocationCoordinate2D) {
//        mapView.setCenter(coordinate, animated: false)
//    }

    func currentOverlayCenter(_ coordinate: CLLocationCoordinate2D) {
        mapView.setCenter(coordinate, animated: false)
    }
    
    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        if overlay.isKind(of: AMap3DObjectOverlay.self) {
            let objOverlay:AMap3DObjectOverlay = overlay as! AMap3DObjectOverlay
            
            let reaverRender: AMap3DObjectOverlayRenderer = AMap3DObjectOverlayRenderer(objectOverlay: overlay as! AMap3DObjectOverlay)
            
            let image:UIImage = UIImage.init(named: objOverlay.textureName)!
            
            reaverRender.loadStrokeTextureImage(image)
            
            return reaverRender
        }
        
        return nil
    }
    
    func mapView(_ mapView: MAMapView!, didAddOverlayRenderers overlayRenderers: [Any]!) {
        perform(#selector(action1), with: nil, afterDelay: 0.5)
        perform(#selector(action2), with: nil, afterDelay: 0.5 + 3)
    }
    
    func action1() {
        mapView.setZoomLevel(17, animated: true)
        mapView.setCenter(airPlaneOverlay.coordinate, animated: true)
        mapView.setCameraDegree(60, animated: true, duration: 1)
        
        let render: AMap3DObjectOverlayRenderer = mapView.renderer(for: airPlaneOverlay) as! AMap3DObjectOverlayRenderer
        
        render.customerDelegate = self
        render.move(toNewCoordinate: CLLocationCoordinate2DMake(39.995001, 116.480644), andDuration: 3)
    }
    
    func action2() {
        mapView.setZoomLevel(19, animated: true)
        mapView.setRotationDegree(40, animated: true, duration: 1)
        mapView.setCameraDegree(60, animated: true, duration: 1)
        mapView.setCenter(carOverlay.coordinate, animated: true)

        let render: AMap3DObjectOverlayRenderer = mapView.renderer(for: carOverlay) as! AMap3DObjectOverlayRenderer
        render.customerDelegate = self

        render.move(toNewCoordinate: CLLocationCoordinate2DMake(39.99537, 116.477174), andDuration: 8)
    }
    
    func houseInit() {
        
        house1 = AMap3DObjectOverlay(center: CLLocationCoordinate2DMake(39.993266, 116.473269),
                                     size: 150,
                                     vertexPointer: pSnow_covered_CottageOBJVerts,
                                     texCoordPointer: pSnow_covered_CottageOBJTexCoords,
                                     vertsNum: Snow_covered_CottageOBJNumVerts)
        
        self.house1.angle = 315
        self.house1.altitude = 5
        self.house1.textureName = "Cottage_Texture.jpg"
        self.mapView.add(self.house1)
        
        self.house2 = AMap3DObjectOverlay(center: CLLocationCoordinate2DMake(39.994794, 116.47762),
                                          size: 150,
                                          vertexPointer: pFarmhouse_OBJVerts,
                                          texCoordPointer: pFarmhouse_OBJTexCoords,
                                          vertsNum: Farmhouse_OBJNumVerts)
        
        self.house2.angle = 40
        self.house2.altitude = 5
        self.house2.textureName = "Farmhouse_Texture.jpg"
        self.mapView.add(self.house2)
    }
    
    func monsterInit() {
        
        self.monsterOverlay = AMap3DObjectOverlay(center: CLLocationCoordinate2DMake(39.996965, 116.478548),
                                                  size: 300,
                                                  vertexPointer: pFelReaverMountVerts,
                                                  texCoordPointer: pFelReaverMountTexCoords,
                                                  vertsNum: FelReaverMountNumVerts)
        
        self.monsterOverlay.angle = 200
        self.monsterOverlay.altitude = 130
        self.monsterOverlay.textureName = "FelReaverMount.png"
        self.mapView.add(self.monsterOverlay)
    }
    
    func carInit() {
        self.carOverlay = AMap3DObjectOverlay(center: CLLocationCoordinate2DMake(39.991289, 116.472575),
                                              size: 35,
                                              vertexPointer: pCombat_VehicleVerts,
                                              texCoordPointer: pCombat_VehicleTexCoords,
                                              vertsNum: Combat_VehicleNumVerts)
        self.carOverlay.angle = 40
        self.carOverlay.altitude = 4
        self.carOverlay.textureName = "V_body.png"
        self.mapView.add(self.carOverlay)
    }
    
    func airPlaneInit() {
        self.airPlaneOverlay = AMap3DObjectOverlay(center: CLLocationCoordinate2DMake(39.984479, 116.494635),
                                                   size: 100,
                                                   vertexPointer: pRaptorVerts,
                                                   texCoordPointer: pRaptorTexCoords,
                                                   vertsNum: raptorNumVerts)
        self.airPlaneOverlay.angle = 128
        self.airPlaneOverlay.altitude = 10
        self.airPlaneOverlay.textureName = "FA-22_Raptor_P01.png"
        self.mapView.add(self.airPlaneOverlay)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        airPlaneInit()
        carInit()
        monsterInit()
        houseInit()

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AMapServices.shared().enableHTTPS = true
        
        //set up mapView
        view.addSubview(mapView)
        mapView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

