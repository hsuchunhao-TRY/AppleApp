import Foundation
internal import Combine

final class CubeEditorModel: ObservableObject {
    @Published var parameters: [CubeActionParameter] = []

    init(original: [CubeActionParameter]) {
        // 深拷貝
        self.parameters = original.map {
            CubeActionParameter(name: $0.name, type: $0.type, used: $0.used, isHidden: $0.isHidden)
        }
    }

    func apply(to cube: Cube) {
        for param in parameters {
            switch param.name {
            case "Duration":
                if case .time(let value) = param.type {
                    cube.duration = value
                }
//            case "Repetition Count":
//                if case .value(let value) = param.type {
//                    cube.repetitionCount = value
//                }
//            case "Enable Sound":
//                if case .toggle(let value) = param.type {
//                    cube.enableSound = value
//                }
            default:
                break
            }
        }
    }

}
