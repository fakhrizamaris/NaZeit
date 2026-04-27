import Foundation
import CoreLocation
import MapKit

let sem = DispatchSemaphore(value: 0)

Task {
    let fromReq = MKLocalSearch.Request()
    fromReq.naturalLanguageQuery = "Batam"
    let fromSearch = MKLocalSearch(request: fromReq)
    let fromRes = try? await fromSearch.start()
    let fromTZ = fromRes?.mapItems.first?.timeZone
    
    let toReq = MKLocalSearch.Request()
    toReq.naturalLanguageQuery = "Moscow"
    let toSearch = MKLocalSearch(request: toReq)
    let toRes = try? await toSearch.start()
    let toTZ = toRes?.mapItems.first?.timeZone
    
    print("Batam TZ: \(String(describing: fromTZ?.identifier)) | GMT offset: \(fromTZ?.secondsFromGMT() ?? 0)")
    print("Moscow TZ: \(String(describing: toTZ?.identifier)) | GMT offset: \(toTZ?.secondsFromGMT() ?? 0)")
    
    exit(0)
}

RunLoop.main.run()
