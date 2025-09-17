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
        let exercise = Exercise(context: viewContext, 
                               name: name, 
                               sets: sets, 
                               reps: reps, 
                               weight: weight, 
                               workout: workout)
        
        // Check if this is a PR
        exercise.checkForPR(context: viewContext)
        
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
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Exercise.workout.date, ascending: false)]
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
        let workout = Workout(context: context, 
                             date: Date(), 
                             dayType: DayType.push.rawValue, 
                             notes: "Great workout!")
        
        // Add sample exercises
        _ = Exercise(context: context, name: "Bench Press", sets: 3, reps: 8, weight: 135.0, workout: workout)
        _ = Exercise(context: context, name: "Incline Press", sets: 3, reps: 10, weight: 115.0, workout: workout)
        
        try? context.save()
    }
}
