import SwiftUI
import SwiftData

struct MainView: View {
    @Environment(\.modelContext) private var context

    @State private var viewModel: CubeViewModel?

    var body: some View {
        VStack {
            if let vm = viewModel {
                List(vm.cubes) { cube in
                    CubeStyleView(cube: cube, style: .basic)
                }
            }
        }
        .onAppear {
            viewModel = CubeViewModel(context: context)
        }
    }
}
