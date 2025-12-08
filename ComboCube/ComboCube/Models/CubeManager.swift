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

        var ids = parent.childrenIDs
        ids.append(child.id)
        parent.childrenIDs = ids

        save()
    }

    /// 指定位置插入 child
    func insertChild(_ child: Cube, into parent: Cube, at index: Int) {
        context.insert(child)

        var ids = parent.childrenIDs
        let safeIndex = min(max(index, 0), ids.count)
        ids.insert(child.id, at: safeIndex)
        parent.childrenIDs = ids

        save()
    }

    /// 從 parent 移除 child
    func removeChild(_ child: Cube, from parent: Cube) {
        var ids = parent.childrenIDs
        ids.removeAll { $0 == child.id }
        parent.childrenIDs = ids

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
        var ids = parent.childrenIDs

        guard oldIndex != newIndex,
              ids.indices.contains(oldIndex) else { return }

        let item = ids.remove(at: oldIndex)
        let safeIndex = min(max(newIndex, 0), ids.count)
        ids.insert(item, at: safeIndex)

        parent.childrenIDs = ids
        save()
    }

    /// 向上移動一格
    func moveUp(child: Cube, in parent: Cube) {
        let ids = parent.childrenIDs

        guard let index = ids.firstIndex(of: child.id),
              index > 0 else { return }

        moveChild(in: parent, from: index, to: index - 1)
    }

    /// 向下移動一格
    func moveDown(child: Cube, in parent: Cube) {
        let ids = parent.childrenIDs

        guard let index = ids.firstIndex(of: child.id),
              index < ids.count - 1 else { return }

        moveChild(in: parent, from: index, to: index + 1)
    }

    /// 給 SwiftUI 的 Drag 使用（IndexSet 轉 index）
    func reorderByDrag(in parent: Cube, from offsets: IndexSet, to destination: Int) {
        guard let fromIndex = offsets.first else { return }
        moveChild(in: parent, from: fromIndex, to: destination)
    }

    // MARK: - 複製

    /// 複製單一 cube（不含 children）
    func duplicateItem(_ cube: Cube) -> Cube {
        let newCube = cube.copyItem()
        context.insert(newCube)
        save()
        return newCube
    }

    /// 複製 child 並插入同一 combo 中
    func duplicateChild(_ child: Cube, in parent: Cube) {
        let copy = child.copyItem()
        context.insert(copy)

        var ids = parent.childrenIDs

        if let index = ids.firstIndex(of: child.id) {
            ids.insert(copy.id, at: index + 1)
        } else {
            ids.append(copy.id)
        }

        parent.childrenIDs = ids
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
