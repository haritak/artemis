class CreateCarPoolsAction < ScheduleBaseAction
  def describe
    "Creating pools of cars using GroupFixer"
  end

  def process(m)
    first_pass = super
    return first_pass if first_pass!=CONTINUE
    return CONTINUE if not @fromSchedulers
    return CONTINUE if not @aboutSchedule and not @aboutEfimeries

    xls_filename = find_and_saveLocal("EXCEL.xls")
    if nil
      return "Error saving EXCEL.xls"
    end

    return CONTINUE
  end
end
