class UpdateScheduleGroupsAction < ScheduleBaseAction
  def describe
    "Updating schedule related databases"
  end
  def process(m)
    super
    return CONTINUE if not @fromSchedulers
    return CONTINUE if not @aboutSchedule or not @aboutEfimeries
  end
end
