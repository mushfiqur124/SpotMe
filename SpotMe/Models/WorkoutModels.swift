//
//  WorkoutModels.swift
//  SpotMe
//
//  Core data models for workout tracking
//  Referenced from PRD: Workout and Exercise entities
//

import Foundation
import CoreData

// MARK: - Workout Entity Extension
extension Workout {
    
    /// Convenience initializer for creating a new workout
    convenience init(context: NSManagedObjectContext, date: Date = Date(), dayType: String = "", notes: String = "") {
        self.init(context: context)
        self.date = date
        self.dayType = dayType
        self.notes = notes
        self.id = UUID()
    }
}

// MARK: - Exercise Entity Extension  
extension Exercise {
    
    /// Convenience initializer for creating a new exercise
    convenience init(context: NSManagedObjectContext, 
                    name: String, 
                    sets: Int16, 
                    reps: Int16, 
                    weight: Double, 
                    workout: Workout) {
        self.init(context: context)
        self.id = UUID()
        self.name = name
        self.sets = sets
        self.reps = reps
        self.weight = weight
        self.totalWeight = Double(sets) * Double(reps) * weight
        self.prFlag = false
        self.workout = workout
    }
    
    /// Calculate total weight lifted for this exercise
    func calculateTotalWeight() {
        totalWeight = Double(sets) * Double(reps) * weight
    }
    
    /// Check if this is a personal record
    func checkForPR(context: NSManagedObjectContext) {
        let request: NSFetchRequest<Exercise> = Exercise.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@ AND weight < %f", name ?? "", weight)
        
        do {
            let previousExercises = try context.fetch(request)
            if !previousExercises.isEmpty {
                prFlag = true
            }
        } catch {
            print("Error checking for PR: \(error)")
        }
    }
}

// MARK: - Day Type Enum
enum DayType: String, CaseIterable {
    case push = "Push"
    case pull = "Pull" 
    case legs = "Legs"
    case shoulders = "Shoulders"
    case chest = "Chest"
    case back = "Back"
    case arms = "Arms"
    case cardio = "Cardio"
    case rest = "Rest"
    
    var emoji: String {
        switch self {
        case .push: return "💪"
        case .pull: return "🏋️"
        case .legs: return "🦵"
        case .shoulders: return "🤸"
        case .chest: return "💯"
        case .back: return "🔥"
        case .arms: return "💪"
        case .cardio: return "🏃"
        case .rest: return "😴"
        }
    }
}
