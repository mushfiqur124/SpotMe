//
//  CoreDataManager.swift
//  SpotMe
//
//  CoreData helper functions and CRUD operations
//  Referenced from Cursor Rules: CRUD helper functions, async queries
//

import Foundation
import CoreData
import SwiftUI

class CoreDataManager: ObservableObject {
    static let shared = CoreDataManager()
    
    private let persistenceController = PersistenceController.shared
    
    var viewContext: NSManagedObjectContext {
        persistenceController.container.viewContext
    }
    
    private init() {}
    
    // MARK: - Workout CRUD Operations
    
    /// Create a new workout
    func createWorkout(date: Date = Date(), dayType: String, notes: String = "") -> Workout {
        let workout = Workout(context: viewContext, date: date, dayType: dayType, notes: notes)
        saveContext()
        return workout
    }
    
    /// Fetch workouts for the last N days
    func fetchRecentWorkouts(days: Int = 7) -> [Workout] {
        let request: NSFetchRequest<Workout> = Workout.fetchRequest()
        let startDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        
        request.predicate = NSPredicate(format: "date >= %@", startDate as NSDate)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Workout.date, ascending: false)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching recent workouts: \(error)")
            return []
        }
    }
    
    /// Fetch all workouts sorted by date
    func fetchAllWorkouts() -> [Workout] {
        let request: NSFetchRequest<Workout> = Workout.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Workout.date, ascending: false)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching workouts: \(error)")
            return []
        }
    }
    
    // MARK: - Exercise CRUD Operations
    
    /// Add exercise to a workout
    func addExercise(to workout: Workout, name: String, sets: Int16, reps: Int16, weight: Double) -> Exercise {
        let exercise = Exercise(context: viewContext)
        exercise.id = UUID()
        exercise.name = name
        exercise.sets = sets
        exercise.reps = reps
        exercise.weight = weight
        exercise.totalWeight = Double(sets) * Double(reps) * weight
        exercise.prFlag = false // Will implement PR checking later
        exercise.workoutID = workout.id
        
        saveContext()
        return exercise
    }
    
    /// Fetch personal records for a specific exercise
    func fetchPersonalRecords(for exerciseName: String) -> [Exercise] {
        let request: NSFetchRequest<Exercise> = Exercise.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@ AND prFlag == YES", exerciseName)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Exercise.weight, ascending: false)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching PRs for \(exerciseName): \(error)")
            return []
        }
    }
    
    /// Fetch the last time an exercise was performed
    func fetchLastExercise(named exerciseName: String) -> Exercise? {
        let request: NSFetchRequest<Exercise> = Exercise.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", exerciseName)
        // Sort by exercise name for now - workout relationship will be implemented in Phase 4
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Exercise.name, ascending: true)]
        request.fetchLimit = 1
        
        do {
            return try viewContext.fetch(request).first
        } catch {
            print("Error fetching last exercise: \(error)")
            return nil
        }
    }
    
    // MARK: - Context Management
    
    /// Save the managed object context
    func saveContext() {
        do {
            if viewContext.hasChanges {
                try viewContext.save()
            }
        } catch {
            print("Failed to save context: \(error)")
            // In production, handle this more gracefully
        }
    }
    
    /// Delete an object
    func delete(_ object: NSManagedObject) {
        viewContext.delete(object)
        saveContext()
    }
}

// MARK: - Preview Data
extension CoreDataManager {
    
    /// Create sample data for previews and testing
    static func createSampleData(in context: NSManagedObjectContext) {
        // Create sample workout
        let workout = Workout(context: context)
        workout.id = UUID()
        workout.date = Date()
        workout.dayType = DayType.push.rawValue
        workout.notes = "Great workout!"
        
        // Add sample exercises
        let exercise1 = Exercise(context: context)
        exercise1.id = UUID()
        exercise1.name = "Bench Press"
        exercise1.sets = 3
        exercise1.reps = 8
        exercise1.weight = 135.0
        exercise1.totalWeight = 3240.0 // 3 * 8 * 135
        exercise1.prFlag = false
        exercise1.workoutID = workout.id
        
        let exercise2 = Exercise(context: context)
        exercise2.id = UUID()
        exercise2.name = "Incline Press"
        exercise2.sets = 3
        exercise2.reps = 10
        exercise2.weight = 115.0
        exercise2.totalWeight = 3450.0 // 3 * 10 * 115
        exercise2.prFlag = false
        exercise2.workoutID = workout.id
        
        try? context.save()
    }
}
