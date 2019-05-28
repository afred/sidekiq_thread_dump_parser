require 'active_support/core_ext/module/delegation'

module SidekiqThreadDumpParser
  class SidekiqThreadDumpParser
    attr_reader :thread_dump_lines
    def initialize(thread_dump_file)
      @thread_dump_lines = File.readlines(thread_dump_file).map(&:chomp)
    end

    def thread_dumps
      @thread_dumps ||= [].tap do |dumps|
        current_thread = nil
        thread_dump_lines.each do |line|
          if (thread_id, thread_type = thread_id_and_type_from_line(line))
            dumps << current_thread if current_thread
            current_thread = ThreadDump.new(thread_id, thread_type)
          end
          current_thread.add_line(line) if current_thread
        end
      end
    end

    def filter(filters={})
      found = thread_dumps
      filters.each do |filter, val|
        if [:id, :type].include? filter
          found = found.select { |td| td.send(filter) == val }
        elsif filter == :line
          found = found.select { |td| !td.lines.grep(val).empty? }
        else
          raise ArgumentError, "unrecognized filter '#{filter}'"
        end
      end
      found
    end

    class << self
      def thread_id_and_type_from_line(line)
        matches = line.match(/Thread (TID\-[a-z0-9]+)([a-z ]*)\Z/)
        [matches[1], matches[2]].map { |match| match&.strip } if matches
      end
    end

    delegate :thread_id_and_type_from_line, to: :class

    class ThreadDump

      attr_reader :id, :type, :lines

      def initialize(id, type=nil)
        @id, @type = id, type
        @lines = {}
      end

      def add_line(line)
        @lines[@lines.count] = line
      end

      def filter_lines(with: nil, without: nil, head: nil, tail: nil)
        filtered_lines = lines.dup
        Array(with).each do |regex|
          raise ArgumentError, "Regexp expected but #{regex.class} was given" unless regex.is_a? Regexp
          filtered_lines = filtered_lines.select { |_i, line| line =~ regex }
        end

        Array(without).each do |regex|
          raise ArgumentError, "Regexp expected but #{regex.class} was given" unless regex.is_a? Regexp
          filtered_lines = filtered_lines.select { |_i, line| line !~ regex }
        end

        if head
          (0...head.to_i).each do |i|
            line_num = i + 1
            filtered_lines[line_num] = lines[line_num]
          end
        end

        if tail
          (0...tail.to_i).each do |i|
            line_num = lines.count - i
            filtered_lines[line_num] = lines[line_num]
          end
        end

        filtered_lines.sort_by { |line_num, line| line_num }.to_h
      end

      def print_lines(with: nil, without: nil, head: nil, tail: nil)
        out = "Thread ID: #{id}"
        out += "\nShowing lines with:\n  #{Array(with).map(&:inspect).join("\n  ")}" if with
        out += "\nShowing lines without:\n  #{Array(without).map(&:inspect).join("\n  ")}" if without
        out += "\nShowing first #{head} lines" if head
        out += "\nShowing last #{tail} lines" if tail
        out += "\n" + filter_lines(with: with, without: without, head: head, tail: tail).map { |i, line| "#{i.to_s.rjust(4)}: #{line}" }.join("\n") + "\n\n"
      end
    end
  end
end
