//
//  Constants.swift
//  SSC_Lab
//
//  Created by yumii on 09/02/2026.
//

import Foundation
import CoreGraphics

enum Constants {
    
    // UI
    enum Strings {
        static let activeStatus  = "ACTIVE"
        static let quickLog      = "QUICK_LOG"
        static let spinWheel     = "SPIN_WHEEL"
    }
    
    // SF Symbols
    enum Icons {
        static let home          = "house"
        static let homeFill      = "house.fill"
        static let checkmark     = "checkmark"
        static let cancel        = "xmark"
        static let dice          = "dice"
        static let log           = "plus.app"
        // StatusBadge
        static let indoor        = "house.fill"
        static let outdoor       = "mountain.2.fill"
        static let tools         = "hammer.fill"
        static let oneTime       = "hands.and.sparkles.fill"
        static let newInterest   = "sparkle.magnifyingglass"
        static let toolsNone     = "ic_WithoutTools"
        static let link          = "link"
    }

    // Experiment Setup card
    enum Setup {
        static let environmentLabel = "Environment"
        static let toolsLabel       = "Tools"
        static let timeframeLabel   = "Timeframe"
        static let logTypeLabel     = "Log type"
        static let indoor           = "Indoor"
        static let outdoor          = "Outdoor"
        static let required         = "Required"
        static let none             = "None"
        static let oneTime          = "One time"
        static let newInterest      = "New Interest"
    }

    // Lab & Experiment  
    enum Lab {
        static let labTitle = "My Lab"
        static let emptyStateTitle = "Tap the + button to start your first experiment!"
        static let emptyStateSubtitle = "Add an experiment to get started."
        static let sectionExperiments = "Experiments"
        static let sectionSetup = "Setup"
        static let sectionReference = "Reference"
        static let buttonAddToLab = "Add To LAB"
        static let buttonSaveChanges = "Save Changes"
        static let headerAddNew = "Add New Experiment"
        static let headerEdit = "Edit Experiment"
        static let discardAlertTitle = "Discard Changes?"
        static let discardAlertMessage = "Are you sure you want to leave without saving?"
        static let discardAlertPrimary = "Discard Changes"
        static let discardAlertSecondary = "Keep Editing"
        static let placeholderNote = "Add a note..."
        static let placeholderReference = "URL:// Insert Reference"
        static let horizontalMargin: CGFloat = 16
        static let gridSpacing: CGFloat = 16
    }

    enum ExperimentDetail {
        static let buttonLogWin = "Log a Win"
        static let buttonLetsDoIt = "Let's do it!"
        static let buttonDelete = "Delete"
        static let buttonEdit = "Edit"
        static let activeAlertTitle = "Active Experiment"
        static let activeAlertMessage = "You already have an active experiment. Do you want to cancel the current one and start this?"
        static let activeAlertStart = "Start This One"
        static let activeAlertSwitch = "Switch"
        static let activeAlertCancel = "Cancel"
        static let paddingHorizontal: CGFloat = 16
        static let spacingBelowCard: CGFloat = 20
        static let spacingNotesToButtons: CGFloat = 16
        static let scrollBottomPadding: CGFloat = 32
    }

    enum WinDetail {
        static let buttonDoItAgain = "Do it again"
        static let buttonDelete = "Delete"
        static let buttonEdit = "Edit"
        static let paddingHorizontal: CGFloat = 16
        static let spacingBelowCard: CGFloat = 20
        static let spacingNotesToButtons: CGFloat = 16
        static let scrollBottomPadding: CGFloat = 32
        static let deletePopUpTitle = "Delete Win?"
        static let deletePopUpMessage = "This action cannot be undone."
        static let deletePopUpPrimary = "Delete"
        static let deletePopUpSecondary = "Cancel"
    }

    // Home page
    enum Home {
        static let currentlyTestingTitle = "Currently Testing"
        static let buttonLogWin = "Log a Win"
        static let buttonStop = "Stop"
        static let emptyStateTitle = "No active experiment"
        static let emptyStateSubtitle = "Go to Lab and start something!"
        static let labStatusPrefix = "Lab Status: "
        static let spinTitle = "SPIN"
        static let quickLogTitle = "QUICK LOG"
        static let lastWinPrefix = "Last Win : "
    }

    // Tab bar
    enum AppTabBar {
        static let homeIcon     = "square.grid.2x2.fill"
        static let homeLabel    = "Home"
        static let labIcon      = "viewfinder.circle.fill"
        static let labLabel     = "Lab"
        static let winsIcon     = "archivebox.fill"
        static let winsLabel    = "Wins"
        static let settingsIcon = "gearshape.fill"
        static let settingsLabel = "Settings"
    }
}
