//
//  CatTranslatorNavigation.swift
//  CatTranslator
//
//  Created by Kazimir Kozulia on 22.04.2025.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct CatTranslatorNavigation {
    
    @Reducer
    enum Path {
        case onboarding(Onboarding)
        case main(Main)
//        case setting(Setting)
//        case payWall(GeneralPaywall)
    }
    
    @ObservableState
    struct State {
        @Shared(.isOnboardingPassed) var isOnboardingPassed = false
        var path = StackState<Path.State>()
        var mainId: StackElementID?
    }
    
    enum Action {
        case path(StackActionOf<Path>)
        case buttonTapped
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .path(.element(id: id, action: .onboarding(.continueButton(.buttonTapped)))):
                guard case let .onboarding(onboarding) = state.path[id: id] else {
                    return .none
                }
                switch onboarding.myType {
                case .first:
                    state.path.append(.onboarding(.init(myType: .second)))
                case .second:
                    state.path.append(.onboarding(.init(myType: .third)))
                case .third:
                    state.path.append(.onboarding(.init(myType: .fourth)))
                case .fourth:
                    state.path.append(.main(.init()))
                }
                return .none
            case let .path(.element(id: id, action: .onboarding(.backCrossButton(.buttonTapped)))):
                guard case  .onboarding = state.path[id: id] else {
                    return .none
                }
                
                state.path.append(.main(.init()))
                state.mainId = state.path.ids.last
                if let mainId = state.mainId {
                    state.path.pop(to: mainId)
                }
                return .none
//            case let .path(.element(id: id, action: .main(.settingButton(.buttonTapped)))):
//                guard case  .main = state.path[id: id] else {
//                    return .none
//                }
//                state.path.append(.setting(.init()))
//                return .none
//            case let .path(.element(id: id, action: .setting(.backCrossButton(.buttonTapped)))):
//                guard case .setting = state.path[id: id] else {
//                    return  .none
//                }
//                if let mainId = state.mainId{
//                    state.path.pop(to: mainId)
//                } else {
//                    state.path.append(.main(.init()))
//                    state.mainId = state.path.ids.last
//                }
//                return .none
            case .path:
                return .none
            case .buttonTapped:
                if state.isOnboardingPassed {
                    state.path.append(.main(.init()))
                } else {
                    state.path.append(.onboarding(.init(myType: .first)))

                }
                return .none
            }
        }
    }
}

struct CatTranslatorNavigationView: View {
    @Bindable var store: StoreOf<CatTranslatorNavigation>
    
    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            Button {
                store.send(.buttonTapped)
            } label: {
                Text("Button")
                    .foregroundStyle(.green)
            }
        } destination: { store in
            switch store.case{
            case let .onboarding(store):
                OnboardingScreens(store: store)
                    .toolbar(.hidden)
            case let .main(store):
                MainScreen(store: store)
                    .toolbar(.hidden)
//            case let .setting(store):
//                SettingScreen(store: store)
//                    .toolbar(.hidden)
//            case .payWall(store):
//                GeneralPaywall(store:store)
//                    .toolbar(.hidden)
            }
        }
        
    }
}

#Preview {
    CatTranslatorNavigationView(
        store: StoreOf<CatTranslatorNavigation>(
            initialState: CatTranslatorNavigation.State(),
            reducer: { CatTranslatorNavigation() }
        )
    )
}

