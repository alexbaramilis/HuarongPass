//
//  Text.swift
//  华容道
//
//  Created by Alexandros Baramilis on 01/03/2019.
//  Copyright © 2019 Alexandros Baramilis. All rights reserved.
//

import Foundation

enum Text {
    static let Solve = "解法 Solve"
    static let Cancel = "取消 Cancel"
    static let NoSolution = "找不到解法。 No solution found."
    static let OK = "好 OK"
    static let ShortestPath_Chinese = "最短路径:"
    static let ShortestPath_English = "Shortest Path:"
    static let Steps_Chinese = "步骤"
    static let Steps_English = "steps"
    static let Step_Chinese = "步骤"
    static let Step_English = "Step"
    static let Two_Step_Any_Direction = "当前设置:\nCurrent setting:\n\n如果方块在不同方向上连续移动两次，移动视作一步。\nIf a piece moves two consecutive blocks in any direction, it will be counted as one step.\n例如/ex. ↑+ → = 1 步骤/step"
    static let Two_Step_One_Direction = "当前设置:\nCurrent setting:\n\n如果方块在单一方向上连续移动两次，移动视作一步。\nIf a piece moves two consecutive blocks in one direction, it will be counted as one step.\n例如/ex. ↑+↑ = 1 步骤/step\n\n如果方块可以在不同方向上移动两次，每次移动视作一步。\nIf a piece moves two consecutive blocks in different directions, it will be counted as two steps.\n例如/ex. ↑+ → = 2 步骤/steps"
    static let AddPiece = "添加方块 Add piece"
    static let Soldier = "士兵 Soldier (1x1)"
    static let Commander1 = "指挥官 Commander (1x2)"
    static let Commander2 = "指挥官 Commander (2x1)"
    static let CaoCao = "曹操 Cao Cao (2x2)"
    static let PieceDoesntFit = "放不下！ The piece doesn't fit!"
    static let AddPieces = "请先添加方块！ Add some pieces to the board！"
    static let AddCaoCao = "别忘了放曹操！ Don't forget to add Cao Cao!"
    static let OneCaoCao = "曹操只能有一个！ There can only be one Cao Cao!"
    static let CustomBoard = "自定义面板 Custom Board"
    static let CustomBoardInfo = "\n点击“+”添加方块，按照左上方式对齐；删除请直接点击方块。\n\nTap on a plus button to place a piece from its top left corner. Tap on a piece to remove it."
}
