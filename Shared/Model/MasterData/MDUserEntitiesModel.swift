//
//  MDUserEntityModel.swift
//  Grocy-SwiftUI
//
//  Created by Georg Meissner on 22.01.21.
//

import Foundation

// MARK: - MDUserEntity
struct MDUserEntity: Codable {
    let id: Int
    let name: String
    let caption: String
    let mdUserEntityDescription: String?
    let showInSidebarMenu: Int?
    let iconCSSClass: String?
    let rowCreatedTimestamp: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case caption
        case mdUserEntityDescription = "description"
        case showInSidebarMenu = "show_in_sidebar_menu"
        case iconCSSClass = "icon_css_class"
        case rowCreatedTimestamp = "row_created_timestamp"
    }
    
    init(from decoder: Decoder) throws {
        do {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            do { self.id = try container.decode(Int.self, forKey: .id) } catch { self.id = Int(try container.decode(String.self, forKey: .id))! }
            self.name = try container.decode(String.self, forKey: .name)
            self.caption = try container.decode(String.self, forKey: .caption)
            self.mdUserEntityDescription = try? container.decodeIfPresent(String.self, forKey: .mdUserEntityDescription) ?? nil
            do { self.showInSidebarMenu = try container.decode(Int.self, forKey: .showInSidebarMenu) } catch { self.showInSidebarMenu = try Int(container.decode(String.self, forKey: .showInSidebarMenu)) }
            self.iconCSSClass = try? container.decodeIfPresent(String.self, forKey: .iconCSSClass) ?? nil
            self.rowCreatedTimestamp = try container.decode(String.self, forKey: .rowCreatedTimestamp)
        } catch {
            throw APIError.decodingError(error: error)
        }
    }
    
    init(id: Int,
         name: String,
         caption: String,
         mdUserEntityDescription: String? = nil,
         showInSidebarMenu: Int? = nil,
         iconCSSClass: String? = nil,
         rowCreatedTimestamp: String) {
        self.id = id
        self.name = name
        self.caption = caption
        self.mdUserEntityDescription = mdUserEntityDescription
        self.showInSidebarMenu = showInSidebarMenu
        self.iconCSSClass = iconCSSClass
        self.rowCreatedTimestamp = rowCreatedTimestamp
    }
}

typealias MDUserEntities = [MDUserEntity]
