//
//  PerformanceTracker.swift
//  UniMetricsSwift
//	This class implements a vary of trackers to measure CPU, RAM and GPU
//  Created by Sam Alonso on 09/03/2024.
//

import Foundation

@objc public class PerformanceTracker: NSObject
{
    @objc public static let shared = PerformanceTracker()

    private var timer: Timer?
    private var cpuUsageValues: [Double] = []
    private var ramUsageValues: [UInt64] = []
	private var timerTrackers = 1.0
    
    private override init() {}
    
    @objc public func startTracking()
    {
        // Reset tracking data
        cpuUsageValues.removeAll()
        ramUsageValues.removeAll()
        
        // Tracker ticks every second
        timer = Timer.scheduledTimer(timeInterval: timerTrackers, target: self, selector: #selector(sampleUsage), userInfo: nil, repeats: true)
    }
    
    @objc public func stopTracking() -> String
    {
        // Invalidate the timer to stop further tracking
        timer?.invalidate()
        timer = nil
        
        let averageCPUUsage = cpuUsageValues.reduce(0.0, +) / Double(cpuUsageValues.count)
        let averageRAMUsage = ramUsageValues.reduce(0, +) / UInt64(ramUsageValues.count)
        
        return "CPU: \(averageCPUUsage)% RAM: \(averageRAMUsage / 1024 / 1024) MB"
    }
    
    @objc private func sampleUsage()
    {
        let currentCPUUsage = self.cpuUsage()
        let currentRAMUsage = self.ramUsage()
        
        cpuUsageValues.append(currentCPUUsage)
        ramUsageValues.append(currentRAMUsage)
    }
    

	//From stackoverflow
	func cpuUsage() -> Double
	{
	  var totalUsageOfCPU: Double = 0.0
	  var threadsList = UnsafeMutablePointer(mutating: [thread_act_t]())
	  var threadsCount = mach_msg_type_number_t(0)
	  let threadsResult = withUnsafeMutablePointer(to: &threadsList) {
		return $0.withMemoryRebound(to: thread_act_array_t?.self, capacity: 1) {
		  task_threads(mach_task_self_, $0, &threadsCount)
		}
	  }
	  
	  if threadsResult == KERN_SUCCESS {
		for index in 0..<threadsCount {
		  var threadInfo = thread_basic_info()
		  var threadInfoCount = mach_msg_type_number_t(THREAD_INFO_MAX)
		  let infoResult = withUnsafeMutablePointer(to: &threadInfo) {
			$0.withMemoryRebound(to: integer_t.self, capacity: 1) {
			  thread_info(threadsList[Int(index)], thread_flavor_t(THREAD_BASIC_INFO), $0, &threadInfoCount)
			}
		  }
		  
		  guard infoResult == KERN_SUCCESS else {
			break
		  }
		  
		  let threadBasicInfo = threadInfo as thread_basic_info
		  if threadBasicInfo.flags & TH_FLAGS_IDLE == 0 {
			totalUsageOfCPU = (totalUsageOfCPU + (Double(threadBasicInfo.cpu_usage) / Double(TH_USAGE_SCALE) * 100.0))
		  }
		}
	  }
	  
	  vm_deallocate(mach_task_self_, vm_address_t(UInt(bitPattern: threadsList)), vm_size_t(Int(threadsCount) * MemoryLayout<thread_t>.stride))
	  return totalUsageOfCPU
	}
    
    private func ramUsage() -> UInt64
    {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            return info.resident_size
        } else {
            return 0
        }
    }
}
