import UIKit

typealias Meters = Double

enum StoreCategory: CaseIterable {
    case grocery
    case furniture
    case covfefe
    case toy
    case shoe
    case pet
}

struct Location {
    let lat: Double
    let lon: Double

    //Equirectangular approximation
    func distance(to: Location) -> Meters {
        let φ1 = lat * .pi / 180
        let φ2 = to.lat * .pi / 180
        let λ1 = lon * .pi / 180
        let λ2 = to.lon * .pi / 180
        let R = 6371e3

        let x = (λ2 - λ1) * cos((φ1 + φ2)/2)
        let y = φ2 - φ1
        return sqrt(x*x + y*y) * R
    }
}

struct Store {
    let location: Location
    let name: String
    let category: StoreCategory
}

func randomLocation() -> Location {
    return Location(
        lat: Double.random(in: 47 ... 48),
        lon: Double.random(in: -122.2 ... -122))
}

func randomName() -> String {
    let p = ["Dollar", "Star", "Pet", "Auto", "Pancake"]
    let s = ["Store", "Buck", "Barn", "Depo", "Factory"]

    return "\(p.randomElement()!) \(s.randomElement()!)"
}

let stores = (1...50).map { _ in
    Store(location: randomLocation(),
          name: randomName(),
          category: StoreCategory.allCases.randomElement()!)
}

let myLocation = Location(lat: 47.67, lon: -122.195)

// Find three coffee shops closest to myLocation
// and print store name and distance for each

func nearToFar(first: Store, second: Store) -> Bool {
    return first.location.distance(to: myLocation) < second.location.distance(to: myLocation)
}

let coffeeShops = stores
    .filter { store in store.category == .covfefe }
    .map { (name: $0.name, distance: $0.location.distance(to: myLocation)) }
    .sorted { $0.distance < $1.distance }
    .prefix(3)

for store in coffeeShops {
    print (store.name, store.distance.rounded())
}

