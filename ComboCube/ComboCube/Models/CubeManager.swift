import Foundation
import SwiftData

@MainActor
final class CubeManager {

    let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    // MARK: - 基本 CRUD

    /// 新增 child 到 parent 最後
    func addChild(_ child: Cube, to parent: Cube) {
        context.insert(child)
        parent.children.append(child)
        save()
    }

    /// 指定位置插入 child
    func insertChild(_ child: Cube, into parent: Cube, at index: Int) {
        context.insert(child)

        let safeIndex = min(max(index, 0), parent.children.count)
        parent.children.insert(child, at: safeIndex)

        save()
    }

    /// 從 parent 移除 child
    func removeChild(_ child: Cube, from parent: Cube) {
        parent.children.removeAll { $0.id == child.id }
        context.delete(child)
        save()
    }

    /// 刪除 cube（外部直接刪）
    func deleteCube(_ cube: Cube) {
        context.delete(cube)
        save()
    }

    // MARK: - 排序 / 移動

    /// 依 index 移動 child（不依賴 SwiftUI）
    func moveChild(in parent: Cube, from oldIndex: Int, to newIndex: Int) {
        guard oldIndex != newIndex,
              parent.children.indices.contains(oldIndex) else { return }

        let item = parent.children.remove(at: oldIndex)

        let safeIndex = min(max(newIndex, 0), parent.children.count)
        parent.children.insert(item, at: safeIndex)

        save()
    }

    /// 向上移動一格
    func moveUp(child: Cube, in parent: Cube) {
        guard let index = parent.children.firstIndex(where: { $0.id == child.id }),
              index > 0 else { return }

        moveChild(in: parent, from: index, to: index - 1)
    }

    /// 向下移動一格
    func moveDown(child: Cube, in parent: Cube) {
        guard let index = parent.children.firstIndex(where: { $0.id == child.id }),
              index < parent.children.count - 1 else { return }

        moveChild(in: parent, from: index, to: index + 1)
    }

    /// 給 SwiftUI 的 Drag 使用（IndexSet 轉實體移動）
    func reorderByDrag(in parent: Cube, from offsets: IndexSet, to destination: Int) {
        guard let fromIndex = offsets.first else { return }
        moveChild(in: parent, from: fromIndex, to: destination)
    }

    // MARK: - 複製

    /// 複製單一 item（不含 children）
    func duplicateItem(_ cube: Cube) -> Cube {
        let newCube = cube.copyItem()   // 你之前寫好的 copy()
        context.insert(newCube)
        save()
        return newCube
    }

    /// 複製 child 並插入同一 combo 中
    func duplicateChild(_ child: Cube, in parent: Cube) {
        let copy = child.copyItem()
        context.insert(copy)

        if let index = parent.children.firstIndex(where: { $0.id == child.id }) {
            parent.children.insert(copy, at: index + 1)
        } else {
            parent.children.append(copy)
        }

        save()
    }

    // MARK: - 儲存

    private func save() {
        do {
            try context.save()
        } catch {
            print("❌ CubeManager save failed:", error)
        }
    }
}
