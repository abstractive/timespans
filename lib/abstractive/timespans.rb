require 'date'
require 'time'
require 'hitimes'
require 'abstractive'

class Abstractive::TimeSpans
  module Methods

    MINUTE = 60
    HOUR = MINUTE*60
    DAY = HOUR*24

    def notated_time_length(span)
      span = time_spans(span) unless span.is_a? Array
      length = ""
      length += "#{span[0]}d " if span[0] > 0
      length += "#{span[1]}h " if span[1] > 0
      length += "#{span[2]}m " if span[2] > 0
      length += "#{span[3]}s "
      length += "#{span[2]}ms " if span[3] > 0
      length.strip
    end
    alias :readable_duration :notated_time_length
    
    def day_decimal(span)
      span = time_spans(span) if span.is_a? Fixnum
      hms = span[1]*HOUR+span[2]*MINUTE+span[3]
      span[0].to_f + (hms.to_f/DAY.to_f)
    end

    def time_spans(length)
      milliseconds = nil
      if length.is_a?(Float)
        milliseconds = ((length - length.floor) * 100).to_i
        length = length.to_i
      end
      days = (length / DAY).floor
      length = length % DAY if days > 0
      hours = (length / HOUR).floor
      length = length % HOUR if hours > 0
      minutes = (length / MINUTE).floor
      length = length % MINUTE if minutes > 0
      seconds = length
      [days, hours, minutes, seconds, milliseconds]
    end

    def plus_span(base, add)
      add = day_decimal(add) unless add.is_a?(Float)
      _ = DateTime.jd(base.to_datetime.jd + add)
      DateTime.strptime(_.strftime('%FT%T')+base.strftime('%:z'))
    end

    def minus_span(base, sub)
      sub = day_decimal(sub) unless sub.is_a?(Float)
      _ = DateTime.jd(base.to_datetime.jd - sub)
      DateTime.strptime(_.strftime('%FT%T')+base.strftime('%:z'))
    end
    
    def duration(start, finish)
      finish.to_i - start.to_i
    end
  end

  include Methods
  extend Methods

  def initialize(i); @i = i end
  def to_i; @i end

  class << self
    def at(text, format=STANDARD_FORMAT)
      DateTime.strptime(text, format).to_time
    rescue => ex
      Abstractive[:logger].exception(ex,"Trouble turning string into DateTime and then Time object.")
    end
  end
end

class Days < Abstractive::TimeSpans;     def to_seconds; @i * DAY      end end
class Hours < Abstractive::TimeSpans;    def to_seconds; @i * HOUR     end end
class Minutes < Abstractive::TimeSpans;  def to_seconds; @i * MINUTE   end end
class Seconds < Abstractive::TimeSpans;  def to_seconds; @i * MINUTE   end end

class Fixnum
  def days;     Days.new(self)      end
  def hours;    Hours.new(self)     end
  def minutes;  Minutes.new(self)   end
  def seconds;  Seconds.new(self)   end
end

class DateTime
   alias old_subtract -
   alias old_add +
   def -(x)
      case x
        when Days;      return Abstractive::TimeSpans.minus_span(self, x.to_seconds)
        when Hours;     return DateTime.new(year, month, day, hour-x.to_i, min, sec, strftime("%:z"))
        when Minutes;   return DateTime.new(year, month, day, hour, min-x.to_i, sec, strftime("%:z"))
        when Seconds;   return DateTime.new(year, month, day, hour, min, sec-x.to_i, strftime("%:z"))
        else;           return self.old_subtract(x)
      end
   end
   def +(x)
      case x
        when Days;      return Abstractive::TimeSpans.plus_span(self, x.to_seconds)
        when Hours;     return DateTime.new(year, month, day, hour+x.to_i, min, sec, strftime("%:z"))
        when Minutes;   return DateTime.new(year, month, day, hour, min+x.to_i, sec, strftime("%:z"))
        when Seconds;   return DateTime.new(year, month, day, hour, min, sec+x.to_i, strftime("%:z"))
        else;           return self.old_add(x)
      end
   end
end

class Time
   alias old_subtract -
   alias old_add +
   def -(x)
      case x
        when Days;      return Abstractive::TimeSpans.minus_span(self, x.to_seconds).to_time
        when Hours;     return DateTime.new(year, month, day, hour-x.to_i, min, sec, strftime("%:z")).to_time
        when Minutes;   return DateTime.new(year, month, day, hour, min-x.to_i, sec, strftime("%:z")).to_time
        when Seconds;   return DateTime.new(year, month, day, hour, min, sec-x.to_i, strftime("%:z")).to_time
        else;           return self.old_subtract(x)
      end
   end
   def +(x)
      case x
        when Days;      return Abstractive::TimeSpans.plus_span(self, x.to_seconds).to_time
        when Hours;     return DateTime.new(year, month, day, hour+x.to_i, min, sec, strftime("%:z")).to_time
        when Minutes;   return DateTime.new(year, month, day, hour, min+x.to_i, sec, strftime("%:z")).to_time
        when Seconds;   return DateTime.new(year, month, day, hour, min, sec+x.to_i, strftime("%:z")).to_time
        else;           return self.old_add(x)
      end
   end
end
