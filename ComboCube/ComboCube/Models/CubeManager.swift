import Foundation
import SwiftData

@MainActor
final class CubeManager {

    let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    // MARK: - 基本 CRUD

    /// 新增 child（加入 parent 最後）
    func addChild(_ child: Cube, to parent: Cube) {
        context.insert(child)

        // --- parent 更新 childrenIDs ---
        var ids = parent.childrenIDs
        ids.append(child.id)
        parent.childrenIDs = ids

        // --- child 更新 parentId ---
        child.parentId = parent.id

        save()
    }

    /// 指定 index 插入 child
    func insertChild(_ child: Cube, into parent: Cube, at index: Int) {
        context.insert(child)

        var ids = parent.childrenIDs
        let safeIndex = min(max(index, 0), ids.count)
        ids.insert(child.id, at: safeIndex)
        parent.childrenIDs = ids

        child.parentId = parent.id

        save()
    }

    /// 從 parent 移除 child（但不刪除 child 本身）
    func detachChild(_ child: Cube, from parent: Cube) {
        var ids = parent.childrenIDs
        ids.removeAll { $0 == child.id }
        parent.childrenIDs = ids

        child.parentId = nil
        save()
    }

    /// 從 parent 移除 child 並刪除 child
    func removeChild(_ child: Cube, from parent: Cube) {
        detachChild(child, from: parent)
        context.delete(child)
        save()
    }

    /// 刪除 cube
    /// 1. 剔除 parent 中的 children（如果有父 cube）
    /// 2. 刪除 cube 本身
    func deleteCube(_ cube: Cube) {
        if let parent = findParent(of: cube) {
            detachChild(cube, from: parent)
        }

        context.delete(cube)
        save()
    }

    // MARK: - 排序 / 移動

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

    func moveUp(child: Cube, in parent: Cube) {
        let ids = parent.childrenIDs

        guard let index = ids.firstIndex(of: child.id),
              index > 0 else { return }

        moveChild(in: parent, from: index, to: index - 1)
    }

    func moveDown(child: Cube, in parent: Cube) {
        let ids = parent.childrenIDs

        guard let index = ids.firstIndex(of: child.id),
              index < ids.count - 1 else { return }

        moveChild(in: parent, from: index, to: index + 1)
    }

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

    /// 複製 child 並插入同一 parent
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
        copy.parentId = parent.id
        save()
    }

    // MARK: - Parent / Children Query

    /// 找 parent Cube
    func findParent(of cube: Cube) -> Cube? {
        guard let pid = cube.parentId else { return nil }
        return try? context.fetch(FetchDescriptor<Cube>())
            .first(where: { $0.id == pid })
    }

    /// 取得 children（以 childrenIDs 順序）
    func getChildren(of parent: Cube) -> [Cube] {
        let all = (try? context.fetch(FetchDescriptor<Cube>())) ?? []
        let map = Dictionary(uniqueKeysWithValues: all.map { ($0.id, $0) })

        return parent.childrenIDs.compactMap { map[$0] }
    }

    // MARK: - Debug Tools

    /// 印出所有 cube（不含 children info）
    func cubeList() -> String {
        let cubes = (try? context.fetch(FetchDescriptor<Cube>())) ?? []
        return cubes.map { "• \($0.title) [\($0.id)]" }.joined(separator: "\n")
    }

    /// 印詳情（包含 parent / children）
    func cubeInfo(_ cube: Cube) -> String {
        let text = """
        --------------------------------
        Cube Info
        title: \(cube.title)
        id: \(cube.id)
        parentId: \(cube.parentId?.uuidString ?? "nil")
        children: \(cube.childrenIDs.count)
        - \(cube.childrenIDs.map { $0.uuidString }.joined(separator: "\n  "))
        --------------------------------
        """

        return text
    }

    // MARK: - Save

    private func save() {
        do {
            try context.save()
        } catch {
            print("❌ CubeManager save failed:", error)
        }
    }
}

@MainActor
extension CubeManager {

    /// 用模板建立 parent + children cubes，並儲存到 DB
    static func createCubes(parentTemplate: CubeTemplate, childrenTemplates: [CubeTemplate], context: ModelContext) -> Cube {
        let manager = CubeManager(context: context)

        // 建立 children
        var childrenCubes: [Cube] = []
        for childTemplate in childrenTemplates {
            let childCube = Cube(
                title: childTemplate.title,
                icon: childTemplate.icon,
                backgroundColor: childTemplate.backgroundColor,
                actionType: childTemplate.actionType,
                tags: childTemplate.tags,
                actionParameters: childTemplate.defaultParameters
            )
            context.insert(childCube)
            childrenCubes.append(childCube)
        }

        // 建立 parent
        let parentCube = Cube(
            title: parentTemplate.title,
            icon: parentTemplate.icon,
            backgroundColor: parentTemplate.backgroundColor,
            actionType: parentTemplate.actionType,
            tags: parentTemplate.tags,
            actionParameters: parentTemplate.defaultParameters
        )
        context.insert(parentCube)

        // 連結 parent/children
        for child in childrenCubes {
            parentCube.appendChild(child)
            child.parentId = parentCube.id
        }

        // 儲存
        do {
            try context.save()
        } catch {
            print("❌ CubeManager.createCubes save failed:", error)
        }

        return parentCube
    }
}
