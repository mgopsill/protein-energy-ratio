//
//  ContentView.swift
//  PERatio
//
//  Created by Mike Gopsill on 17/05/2020.
//  Copyright © 2020 mgopsill. All rights reserved.
//

import Combine
import SwiftUI

struct ContentView: View {
    @ObservedObject private var keyboard = KeyboardResponder()
    @ObservedObject private var vm = ContentViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20.0) {
                    MacroSliderContainerView(gramsOfProtein: $vm.gramsOfProtein,
                                             gramsOfFat: $vm.gramsOfFat,
                                             gramsOfCarb: $vm.gramsOfCarb,
                                             gramsOfFiber: $vm.gramsOfFiber)
                    LabelsView(calories: vm.calories,
                               proteinPercent: vm.proteinPercent,
                               fatPercent: vm.fatPercent,
                               carbPercent: vm.carbPercent,
                               proteinEnergy: vm.ratio,
                               vector: vm.vector)
                    GraphView(degrees: vm.vector,
                              ratio: vm.ratio)
                    Text("P:E Ratio")
                        .fontWeight(.semibold)
                        .font(Font.system(size: 8.0))
                        .foregroundColor(.accentColor)
                        .padding(20.0)
                }
                .navigationBarTitle("Protein : Energy")
                .padding()
                
            }
            .padding(.bottom, keyboard.currentHeight)
            .edgesIgnoringSafeArea(.bottom)
        }
    }
}

final class ContentViewModel: ObservableObject {
    @Published var gramsOfProtein: Float = 0.0
    @Published var gramsOfFat: Float = 0.0
    @Published var gramsOfCarb: Float = 0.0
    @Published var gramsOfFiber: Float = 0.0
    
    @Published var calories: Int = 0
    @Published var proteinPercent: Int = 0
    @Published var fatPercent: Int = 0
    @Published var carbPercent: Int = 0
    @Published var ratio: Float = 0.0
    @Published var vector: Float = 0.0
    
    var cancellables: Set<AnyCancellable>? = []
    
    init() {
        let proteinCalories = $gramsOfProtein.map(proteinAsCalories)
        let fatCalories = $gramsOfFat.map(fatAsCalories)
        let carbohydrateCalories = $gramsOfCarb.combineLatest($gramsOfFiber).map(carbsMinusFiber)
        let calories = proteinCalories.combineLatest(fatCalories, carbohydrateCalories).map(sum)
        
        let proteinPercent = calories.map(Float.init).combineLatest(proteinCalories.map(Float.init)).map(percent)
        let fatPercent = calories.map(Float.init).combineLatest(fatCalories.map(Float.init)).map(percent)
        let carbPercent = calories.map(Float.init).combineLatest(carbohydrateCalories.map(Float.init)).map(percent)
        
        let proteinRatio = $gramsOfProtein.combineLatest($gramsOfFat, $gramsOfCarb, $gramsOfFiber).map(ratio)
        let nutritionalVector = proteinRatio.map(vector)
        
        cancellables?.insert(calories.assign(to: \.calories, on: self))
        cancellables?.insert(proteinPercent.assign(to: \.proteinPercent, on: self))
        cancellables?.insert(fatPercent.assign(to: \.fatPercent, on: self))
        cancellables?.insert(carbPercent.assign(to: \.carbPercent, on: self))
        cancellables?.insert(proteinRatio.assign(to: \.ratio, on: self))
        cancellables?.insert(nutritionalVector.assign(to: \.vector, on: self))
        
        let fiberRaisesCarb = $gramsOfFiber.combineLatest($gramsOfCarb)
            .filter { (fiber, carb) -> Bool in
                return fiber > carb
        }.map { (fiber, carb) -> Float in
            return fiber
        }.assign(to: \.gramsOfCarb, on: self)
        
        let carbLowersFiber = $gramsOfCarb.combineLatest($gramsOfFiber)
            .filter { (carb, fiber) -> Bool in
                return fiber > carb
        }.map { (carb, fiber) -> Float in
            return carb
        }.assign(to: \.gramsOfFiber, on: self)
        
        cancellables?.insert(fiberRaisesCarb)
        cancellables?.insert(carbLowersFiber)
    }
    
    func proteinAsCalories(_ float: Float) -> Int {
        return Int(float * 4)
    }
    
    func fatAsCalories(_ float: Float) -> Int {
        return Int(float * 9)
    }
    
    func carbsMinusFiber(_ carbs: Float, _ fiber: Float) -> Int {
        return Int(carbs - fiber) * 4
    }
    
    func sum(_ a: Int, _ b: Int, _ c: Int) -> Int {
        return a + b + c
    }
    
    func percent(_ a: Float, _ b: Float) -> Int {
        guard a > 0 && b > 0 else { return 0 }
        return Int((b / a) * 100)
    }
    
    func ratio(_ protein: Float, _ fat: Float, _ carbohydrates: Float, _ fiber: Float) -> Float {
        let ratio = protein / (fat + carbohydrates - fiber)
        let returnValue = (ratio * 100).rounded(.toNearestOrEven) / 100
        return returnValue > 0 ? returnValue : 0
    }
    
    func vector(_ ratio: Float) -> Float {
        let vector = atan(ratio) * 180 / Float.pi
        return (vector * 100).rounded(.toNearestOrEven) / 100
    }
    
    func fiberIsLessThanCarb(_ fiber: Float, _ carb: Float) -> Bool {
        return fiber < carb
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
