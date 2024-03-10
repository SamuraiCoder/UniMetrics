//
//  PerformanceTracker.swift
//  UniMetricsSwift
//	This class implements a vary of trackers to measure CPU, RAM and GPU
//  Created by Sam Alonso on 09/03/2024.
//

import Foundation
import MetricKit

@objc public class PerformanceTracker: NSObject, MXMetricManagerSubscriber
{
    @objc public static let shared = PerformanceTracker()
    
    private var lastCumulativeGPUTime: TimeInterval?
    private var trackingStartTime: Date?
    private var currentThermalState: ProcessInfo.ThermalState = ProcessInfo.processInfo.thermalState
	private var timer: Timer?
    private var cpuUsageValues: [Double] = []
    private var ramUsageValues: [UInt64] = []
	private var timerTrackers = 1.0

	override init()
	{
        super.init()
        // Subscribe to MetricKit's metric manager
        MXMetricManager.shared.add(self)
        // Subscribe to Thermal states changes
        NotificationCenter.default.addObserver(self, selector: #selector(thermalStateDidChange), name: ProcessInfo.thermalStateDidChangeNotification, object: nil)
    }
    
	@objc private func thermalStateDidChange(notification: NSNotification)
	{
		currentThermalState = ProcessInfo.processInfo.thermalState
    }
    
    // Unsubscribe from notifiers
	deinit
	{
		MXMetricManager.shared.remove(self)
        NotificationCenter.default.removeObserver(self)
    }
        
    @objc public func startTracking()
    {
        trackingStartTime = Date()

        // Reset tracking data
        cpuUsageValues.removeAll()
        ramUsageValues.removeAll()
        
        // Tracker ticks every second
        timer = Timer.scheduledTimer(timeInterval: timerTrackers, target: self, selector: #selector(sampleUsage), userInfo: nil, repeats: true)
    }
    
    @objc public func stopTracking() -> String
    {
        guard let startTime = trackingStartTime else { return "Tracking wasn't started." }
        
        // Invalidate the timer to stop further tracking
        timer?.invalidate()
        timer = nil

		// Get the averages and construct the returning JSON
        let averageCPUUsage = cpuUsageValues.isEmpty ? 0.0 : cpuUsageValues.reduce(0.0, +) / Double(cpuUsageValues.count)
        let averageRAMUsage = ramUsageValues.isEmpty ? 0 : ramUsageValues.reduce(0, +) / UInt64(ramUsageValues.count)
		
		let appRuntime = Date().timeIntervalSince(startTime)
		
		var utilizationPercentage = 0
        if let gpuTime = lastCumulativeGPUTime
        {
			utilizationPercentage = Int((gpuTime / appRuntime) * 100)
        }
        
		let thermalStateDescription = describe(thermalState: currentThermalState)

        
        let dataDict: [String: Any] = [
            "cpuUsage": averageCPUUsage,
            "ramUsage": averageRAMUsage / 1024 / 1024, // Convert to MB
            "gpuUsage": utilizationPercentage,
            "thermal" : thermalStateDescription
        ]

        // Serialize the dictionary to a JSON string
        if let jsonData = try? JSONSerialization.data(withJSONObject: dataDict, options: []),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        } else {
            return "{}" //Empty if serialisation fails
        }
    }
    
    @objc private func sampleUsage()
    {
        let currentCPUUsage = self.cpuUsage()
        let currentRAMUsage = self.ramUsage()
        
        cpuUsageValues.append(currentCPUUsage)
        ramUsageValues.append(currentRAMUsage)
    }
    
    public func didReceive(_ payloads: [MXMetricPayload])
    {
        guard let payload = payloads.first else { return }
        
        if let gpuMetrics = payload.gpuMetrics
        {
            lastCumulativeGPUTime = gpuMetrics.cumulativeGPUTime.value
        }
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
    
	private func describe(thermalState: ProcessInfo.ThermalState) -> String
	{
		switch thermalState
		{
			case .nominal:
				return "Nominal"
			case .fair:
				return "Fair"
			case .serious:
				return "Serious"
			case .critical:
				return "Critical"
			@unknown default:
				return "Unknown"
		}
    }
}
