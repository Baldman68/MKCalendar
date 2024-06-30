// The Swift Programming Language
// https://docs.swift.org/swift-book

//
//  CalendarViewControl.swift
//  MobileGoRecruit
//
//  Created by Michael Kacos on 6/26/24.
//

import SwiftUI

@available(iOS 17.0, *)
public struct MKCalendar: View {
    @Binding public var visibleMonth: Int
    @Binding public var visibleYear: Int
    @Binding public var selectedDate: Date
    @Binding public var datesWithEvents: [Date]?
    @State public var dayOfWeek = 0
    @State public var datesOfMonth: [Date] = .init()
    @State public var isShowingPicker: Bool = false
    @State public var calendarPageView: Binding<CalendarPageType> = .constant(CalendarPageType.thisMonth)
    @State public var selectedPage = CalendarPageType.thisMonth
    
    public let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    public init(visibleMonth: Binding<Int>, visibleYear: Binding<Int>, selectedDate: Binding<Date>, datesWithEvents: Binding<[Date]?>) {
        self._visibleMonth = visibleMonth
        self._visibleYear = visibleYear
        self._selectedDate = selectedDate
        self._datesWithEvents = datesWithEvents
        
    }

    public var body: some View {
       
            VStack {
                if isShowingPicker {
                    MonthAndYearPicker(year: $visibleYear, month: $visibleMonth, isShowingPicker: $isShowingPicker)
                }
                else {
                    
                        VStack {
                            HStack {
                                Button(action: {
                                    isShowingPicker.toggle()
                                }, label: {
                                    Text("\(getMonthName(monthNum: visibleMonth)) \(visibleYear.description)")
                                        .font(.body)
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.accentColor)
                                        .font(.body)
                                    
                                })
                                
                                Spacer()
                                
                                Button(action: {
                                    goToLastMonth()
                                }, label: {
                                    Image(systemName: "chevron.left")
                                        .foregroundColor(.accentColor)
                                        .imageScale(.large)
                                })
                                .padding(.trailing)
                                
                                Button(action: {
                                    goToNextMonth()
                                }, label: {
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.accentColor)
                                        .imageScale(.large)
                                })
                            }
                            
                            
                            VStack {
                                LazyVGrid(columns: columns, spacing: 20) {
                                    Text("SUN")
                                    Text("MON")
                                    Text("TUE")
                                    Text("WED")
                                    Text("THU")
                                    Text("FRI")
                                    Text("SAT")
                                }
                                .foregroundColor(.secondary.opacity(0.4))
                                .font(.footnote)
                                                                
                                TabView(selection: pageSelection()) {
                                    Image(systemName: "arrowshape.left.fill")
                                        .imageScale(.large)
                                        .tag(CalendarPageType.lastMonth)
                                    
                                    LazyVGrid(columns: columns, spacing: 20) {
                                        ForEach(datesOfMonth, id: \.self) { day in
                                            VStack {
                                                ZStack {
                                                    Circle()
                                                        .foregroundColor(areDatesEqual(date1: selectedDate, date2: day) ? .accentColor : .clear)
                                                        .frame(width: 30, height: 30)
                                                    
                                                    Text(getDayFromDate(date: day).description)
                                                        .foregroundColor(areDatesEqual(date1: selectedDate, date2: day) ? .white : areDatesEqual(date1: Date(), date2: day) ? .accentColor : isDateInCurrentMonth(date: day) ? .primary : .secondary.opacity(0.4))
                                                        .onTapGesture {
                                                            if isDateInCurrentMonth(date: day) {
                                                                selectedDate = day
                                                            }
                                                        }
                                                }
                                                
                                                Spacer()
                                                
                                                if datesWithEvents != nil && (datesWithEvents?.filter { areDatesEqual(date1: $0, date2: day) }.count)! > 0 {
                                                    Image(systemName: "circle.fill")
                                                        .resizable()
                                                        .foregroundColor(.secondary)
                                                        .frame(width: 4, height: 4)
                                                        .padding(.top, -2)
                                                }
                                                else {
                                                    Image(systemName: "circle.fill")
                                                        .resizable()
                                                        .foregroundColor(.clear)
                                                        .frame(width: 4, height: 4)
                                                        .padding(.top, -2)
                                                }
                                            }
                                            .frame(maxHeight: 34)
                                            .fixedSize(horizontal: true, vertical: true)
                                        }
                                    }
                                        .tag(CalendarPageType.thisMonth)
                                    
                                    Image(systemName: "arrowshape.right.fill")
                                        .imageScale(.large)
                                        .tag(CalendarPageType.nextMonth)
                                }
                                .tabViewStyle(.page(indexDisplayMode: .never))
                            }
                            
                                
                            
                        }
                       
                        
                       
                        
                    
                }
                
            }
            .frame(height: 380)
            .onAppear {
                getDaysOfMonth()
            }
            .onChange(of: visibleMonth) {
                getDaysOfMonth()
            }
            .onChange(of: visibleYear) {
                getDaysOfMonth()
            }
            .onChange(of: datesWithEvents) {
                getDaysOfMonth()
            }
            .onChange(of: isShowingPicker) {
                if isShowingPicker == false {
                    setSelectedDateToNewMonth()
                }
            }
            .onChange(of: selectedPage) {
                if selectedPage == .lastMonth {
                    goToLastMonth()
                    withAnimation {
                        selectedPage = .thisMonth
                    }
                }
                else if selectedPage == .nextMonth {
                    goToNextMonth()
                    withAnimation {
                        selectedPage = .thisMonth
                    }
                }
            }
        
    }
    
    public func getMonthName(monthNum: Int) -> String {
        var rtnVal = "January"
        switch monthNum {
        case 1:
            rtnVal = "January"
        case 2:
            rtnVal = "February"
        case 3:
            rtnVal = "March"
        case 4:
            rtnVal = "April"
        case 5:
            rtnVal = "May"
        case 6:
            rtnVal = "June"
        case 7:
            rtnVal = "July"
        case 8:
            rtnVal = "August"
        case 9:
            rtnVal = "September"
        case 10:
            rtnVal = "October"
        case 11:
            rtnVal = "November"
        case 12:
            rtnVal = "December"
        default:
            rtnVal = "January"
        }
        
        return rtnVal
    }
    
    public func numberOfDaysInMonth(year: Int, month: Int) -> Int {
        let dateComponents = DateComponents(year: year, month: month)
        let calendar = Calendar.current
        let date = calendar.date(from: dateComponents)!

        let range = calendar.range(of: .day, in: .month, for: date)!
        let numDays = range.count
        return numDays
    }
    
    public func getDaysOfMonth() {
        // Number of days in this month
        let numOfDays = numberOfDaysInMonth(year: visibleYear, month: visibleMonth)
        
        // Get info about this month.  Start and end dates and days of week
        let calendar = Calendar.current
        let startDateComponents = DateComponents(year: visibleYear, month: visibleMonth, day: 1)
        let startDate = calendar.date(from: startDateComponents)
        
        let firstDayOfMonth = Calendar.current.dateComponents([.weekday], from: startDate!).weekday!
        
        let endDateComponents = DateComponents(year: visibleYear, month: visibleMonth, day: numOfDays)
        let endDate = calendar.date(from: endDateComponents)
        
        // Get info for last month to fill in greyed out dates when viewing this month
        let lastDayOfMonth = Calendar.current.dateComponents([.weekday], from: endDate!).weekday!
        
        var lastMonth = 0
        var nextMonth = 0
        var theYearToGetLastMonth = visibleYear
        if visibleMonth == 1 {
            lastMonth = 12
            theYearToGetLastMonth = visibleYear - 1
        }
        else {
            lastMonth = visibleMonth - 1
        }
        
        if visibleMonth == 12 {
            nextMonth = 1
        }
        else {
            nextMonth = visibleMonth + 1
        }
        let numberOfDaysInLastMonth = numberOfDaysInMonth(year: theYearToGetLastMonth, month: lastMonth)
        
        datesOfMonth = .init()
        
        if firstDayOfMonth > 1 {
            // Build the array of dates
            for i in 1 ... firstDayOfMonth - 1 {
                datesOfMonth.insert(getDateFromComponents(year: theYearToGetLastMonth, month: lastMonth, day: numberOfDaysInLastMonth - i), at: 0)
            }
        }
        
        for j in 1 ... numOfDays {
            datesOfMonth.append(getDateFromComponents(year: visibleYear, month: visibleMonth, day: j))
        }
        
        if 7 - lastDayOfMonth > 0 {
            for k in 1 ... 7 - lastDayOfMonth {
                datesOfMonth.append(getDateFromComponents(year: visibleYear, month: nextMonth, day: k))
            }
        }
    }
    

    
    public func setSelectedDateToNewMonth() {
        let dateComponents = DateComponents(year: visibleYear, month: visibleMonth, day: 1)
        let calendar = Calendar.current
        var newSelectedDate = calendar.date(from: dateComponents)!
        if Calendar.current.dateComponents([.month], from: newSelectedDate).month! == Calendar.current.dateComponents([.month], from: Date()).month!
        {
            newSelectedDate = Date()
        }
        
        selectedDate = newSelectedDate
    }
    
    public func getDateFromComponents(year: Int, month: Int, day: Int) -> Date {
        let dateComponents = DateComponents(year: year, month: month, day: day)
        let calendar = Calendar.current
        return calendar.date(from: dateComponents)!
    }
    
    public func getDayFromDate(date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date).day!
    }
    
    public func isDateInCurrentMonth(date: Date) -> Bool {
        let theMonth = Calendar.current.dateComponents([.month], from: date).month!
        
        return theMonth == visibleMonth
    }
    
    public func areDatesEqual(date1: Date, date2: Date) -> Bool {
        return Calendar.current.isDate(date1, equalTo: date2, toGranularity: .day)
    }
    
    public func goToLastMonth(){
        if visibleMonth == 1 {
            visibleMonth = 12
            visibleYear = visibleYear - 1
        }
        else {
            visibleMonth = visibleMonth - 1
            
        }
        getDaysOfMonth()
        setSelectedDateToNewMonth()
    }
    
    public func goToNextMonth(){
        if visibleMonth == 12 {
            visibleMonth = 1
            visibleYear = visibleYear + 1
        }
        else {
            visibleMonth = visibleMonth + 1
        }
        getDaysOfMonth()
        setSelectedDateToNewMonth()
    }
}

//public struct MonthDays: Hashable {
//    var dayNumber: Int
//    var dayOfWeekNumber: Int
//}


@available(iOS 17.0, *)
public struct MonthAndYearPicker: View {
    @Binding var year: Int
    @Binding var month: Int
    @Binding var isShowingPicker: Bool
    
    public var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    isShowingPicker.toggle()
                }, label: {
                    Text("Done")
                })
            }
            .padding(.trailing)
            HStack {
                Picker("Year", selection: $year, content: {
                    ForEach(0 ..< 3000) { theYear in
                        if theYear > 1900 && theYear < 3000 {
                            Text(theYear.description)
                        }
                    }
                })
                .pickerStyle(.wheel)
                
                Picker("Month", selection: $month, content: {
                    ForEach(1 ..< 13, id: \.self) { theMonth in
                        switch theMonth {
                        case 1:
                            Text("January")
                        case 2:
                            Text("February")
                        case 3:
                            Text("March")
                        case 4:
                            Text("April")
                        case 5:
                            Text("May")
                        case 6:
                            Text("June")
                        case 7:
                            Text("July")
                        case 8:
                            Text("August")
                        case 9:
                            Text("September")
                        case 10:
                            Text("October")
                        case 11:
                            Text("November")
                        case 12:
                            Text("December")
                        default:
                            Text("January")
                        }
                    }
                })
                .pickerStyle(.wheel)
            }
            Spacer()
        }
    }
    
    
}

public enum CalendarPageType: Int, Equatable {
    case lastMonth = 0
    case thisMonth = 1
    case nextMonth = 2
}

@available(iOS 17.0, *)
extension MKCalendar {
    public func pageSelection() -> Binding<CalendarPageType> {
        Binding { // this is the get block
            self.selectedPage
        } set: { tappedTab in
            self.selectedPage = tappedTab
        }
    }
}
