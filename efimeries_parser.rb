require 'rubygems'
require 'roo'
require 'sqlite3'

class EfimeriesParser

  DaysColumn = 1
  LocationsColumn = 2
  NoIntermissions = 6
  NoLocations = 5 #Είσοδος, Οροφος ... **και** το Αναπληρωτής

  def initialize(filename)
    @efimeries = filename
    @debug = true
  end

  def beSilent
    @debug = false
  end

  # returns OK 
  # or the error that happened
  def parse 

    weekdays = ["Δευτέρα", "Τρίτη", "Τετάρτη", "Πέμπτη", "Παρασκευή"]

    intermissions = {}
    locations = {}
    @teachers = []
    dayrows = {}

    oo = Roo::Spreadsheet.open(@efimeries)

    sheet = oo.sheet(0)

    column = sheet.column(DaysColumn)
    column.each_with_index do |cell,i|
      if weekdays.include?(cell) then
        if dayrows[cell] != nil
          dayrows[cell] << i
        else
          dayrows[cell] = [i]
        end
      end
    end

    p dayrows if @debug

    weekdays.each do |wd|
      if not dayrows.include?(wd)
        return "#{wd} not found!"
      end
    end

    puts "All days were found" if @debug

    intermissions_row_no = dayrows[weekdays[0]][0]

    intermissions_row = sheet.row( intermissions_row_no )

    intermissions_row.each_with_index do |cell, i|
      if cell != nil then
        if intermissions[cell] != nil
          return "Error! #{cell} occurs twice in the same row"
        else
          intermissions[cell] = i
        end
      end
    end

    if intermissions.size != NoIntermissions 
      return "Warning! found less than expected intermissions."
    else
      puts "Number of intermissions seems ok" if @debug
    end


    column = sheet.column(LocationsColumn)
    column.each_with_index do |cell,i|
      if cell.class != String
        next
      end
      if locations[cell] != nil
        locations[cell] << i
      else
        locations[cell] = [i]
      end
    end

    locations.each do |k,v|
      if v.size != weekdays.size
        locations.delete(k)
      end
    end

    if locations.size == NoLocations
      puts "All locations were found" if @debug
    else
      return "Warning! Didn't find all locations"
    end

    #find teachers

    columnOfFirstIntermission = intermissions.values[0]+1
    columnOfLastIntermission = intermissions.values[-1]+1
    rowOfFirstDayFirstPlace = intermissions_row_no + 1
    rowOfLastDayLastPlace = dayrows[ weekdays[4] ][-1] + 1

    puts "Teachers names should be inside the box "+
      "#{rowOfFirstDayFirstPlace},#{columnOfFirstIntermission} and "+
      "#{rowOfLastDayLastPlace}, #{columnOfLastIntermission}" if @debug

      column2intermission={}
      intermissions.each do |k,v|
        colNo = v+1
        if column2intermission[colNo] != nil
          return "Error! Duplicate v for intermission"
        end
        column2intermission[colNo] = k
      end
      #p column2intermission

      row2location = {}
      locations.each do |k,v|
        v.each do |r|
          rowNo=r+1
          if row2location[rowNo] != nil
            return "Error! Duplicate v for location"
          end
          row2location[rowNo] = k
        end
      end
      #p row2location

      row2day={}
      dayrows.each do |k,v|
        v.each do |r|
          rowNo=r+1
          if row2day[rowNo] != nil
            return "Error! Duplicate v for day"
          end
          row2day[rowNo] = k
        end
      end
      #p row2day

      current_row_no = rowOfFirstDayFirstPlace
      while current_row_no <= rowOfLastDayLastPlace
        current_column_no = columnOfFirstIntermission
        while current_column_no<=columnOfLastIntermission
          cell = sheet.cell(current_row_no, current_column_no)
          cell.strip!
          @teachers<<cell unless @teachers.include?(cell)
          current_column_no+=1
        end
        current_row_no+=1
      end

      puts "#{@teachers.size} @teachers found" if @debug
      total_efimeries_per_day = locations.size * intermissions.size
      puts "#{total_efimeries_per_day} are the total number of efimeries" if @debug
      efimeries_per_person = ((total_efimeries_per_day.to_f/@teachers.size) + 0.5).round
      puts "#{efimeries_per_person} efimeries should receive each person per day" if @debug
      puts "#{efimeries_per_person*5} efimeries should receive each person per week" if @debug

      efimeriesPerTeacher = {}
      @teachers.each do |teacher|

        current_row_no = rowOfFirstDayFirstPlace
        while current_row_no <= rowOfLastDayLastPlace
          current_column_no = columnOfFirstIntermission
          while current_column_no<=columnOfLastIntermission
            cell = sheet.cell(current_row_no, current_column_no)

            if cell==teacher
              theDay = row2day[ current_row_no ]
              theLocation = row2location[ current_row_no ]
              theIntermission = column2intermission[ current_column_no ]
              if theDay==nil or theLocation==nil or theIntermission==nil
                return "Miss hit!"
              end
              efimeriesPerTeacher[teacher] = [] if efimeriesPerTeacher[teacher] == nil
              efimeriesPerTeacher[teacher] << [theDay, theLocation,theIntermission]
            end

            current_column_no+=1
          end
          current_row_no+=1
        end
      end

      totalEfimeries = 0
      countEfimeriesPerTeacher = {}
      efimeriesPerTeacher.each do |k,v|
        puts k if @debug
        v.each do |l|
          p l if @debug
        end
        countEfimeriesPerTeacher[ k ] = v.size
        totalEfimeries+=v.size
        puts "-----" if @debug
      end

      p countEfimeriesPerTeacher if @debug
      puts "#{totalEfimeries} efimeries have been assigned" if @debug
      if totalEfimeries!=total_efimeries_per_day*5
        return "Consistency error!"
      end

      return "OK"
  end

  def each_teacher &block
    @teachers.each &block
  end

end
