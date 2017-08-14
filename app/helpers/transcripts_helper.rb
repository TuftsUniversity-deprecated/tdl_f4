module TranscriptsHelper


  def audio_page_path(id)
    "/concern/tufts_audios/" + id
  end


  def video_page_path(id)
    "/concern/tufts_videos/" + id
  end


  def audio_transcriptonly_path(id)
    "/concern/tufts_audios/" + id + "/transcriptonly"
  end


  def dvieo_transcriptonly_path(id)
    "/concern/tufts_videos/" + id + "/transcriptonly"
  end


  def format_participants(participants)
    result = ""
    participant_number = 0

    participants.each do |participant|
      participant_number += 1
      id = participant.initials
      role = participant.role
      sex = participant.gender
      name = participant.name
      result << "        <div class=\"participant_row\" id=\"participant" + participant_number.to_s + "\">\n"
      result << "          <div class=\"participant_id\">" + (id.nil? ? "" : id) + "</div>\n"
      result << "          <div class=\"participant_name\">" + name + "<span class=\"participant_role\">" + (role.nil? ? "" : ", " + role) + (sex.empty? ? "" : " (" + (sex == "f" ? "female" : (sex == "m" ? "male" : sex)) + ")") + "</span></div>\n"
      result << "        </div> <!-- participant_row -->\n"
    end

    if result.length > 0
      result = "<div class=\"participant_table\">\n" + result + "      </div> <!-- participant_table -->\n"
    end

    return result
  end


  # convert fedora transcript object to html
  def show_transcript(tei, active_timestamps, path)
    chunks, participants = TranscriptChunk.parse(tei)
    transcript_html = format_transcript(chunks, active_timestamps, path)
    participant_html = format_participants(participants)

    return transcript_html, participant_html
  end


  def get_time_table(tei)
    chunks = TranscriptChunk.parse(tei)
    table = extract_time_table(chunks)

    return table
  end


  def extract_time_table(chunks)
    table = {}
    chunks.each do |chunk|
      milliseconds = chunk.start_in_milliseconds
      string_minutes, string_just_seconds, string_total_seconds = displayable_time(milliseconds)
      table[chunk.name.to_s] = {:time => milliseconds, :display_time => string_minutes + ":" + string_just_seconds}
    end

    return table
  end


  # return html string of the transcript
  # iterate over chunks and create appropriate divs with classes, links, etc.
  def format_transcript(chunks, active_timestamps, path)
    result = "<div class=\"transcript_table\">\n"
    chunks.each do |chunk|
      milliseconds = chunk.start_in_milliseconds
      string_minutes, string_just_seconds, string_total_seconds = displayable_time(milliseconds)
      div_id = chunk.name

      result << "                <div class=\"transcript_chunk\" id=\"chunk" + string_total_seconds + "\">\n"

      unless (milliseconds.nil?)
        result << "                  <div class=\"transcript_row\">\n"
        result << "                    <div class=\"transcript_speaker\">\n"

        if (active_timestamps)
          result << "                      <a class=\"transcript_chunk_link\" data-time=\"" + milliseconds.to_s + "\" href=\""+ path + "?timestamp=" + string_minutes + ":" + string_just_seconds + "\">" + string_minutes + ":" + string_just_seconds + "</a>\n"
        else
          result << "                      <span class=\"transcript_chunk_link\">" + string_minutes + ":" + string_just_seconds + "</span>\n"
        end

        result << "                    </div> <!-- transcript_speaker -->\n"
        result << "                    <div class=\"transcript_utterance\"></div>\n"
        result << "                  </div> <!-- transcript_row -->\n"
      end

      utterances = chunk.utterances
      utterances.each do |utterance|
        who = utterance.speaker_initials
        text = utterance.text
        timepoint_id = utterance.timepoint_id

        if (who)
          result << "                  <div class=\"transcript_row\">\n"
          result << "                    <div class=\"transcript_speaker\">"+ (who.nil? ? "" : who) + "</div>\n"
          result << "                    <div class=\"transcript_utterance\"  id=\""+timepoint_id+"\">"+ (text.nil? ? "" : text) + "</div>\n"
          result << "                  </div> <!-- transcript_row -->\n"
        else
          unless text.nil?
            result << "                  <div class=\"transcript_row\">\n"
            result << "                    <div class=\"transcript_speaker\">" "</div>\n"
            result << "                    <div class=\"transcript_utterance\" id=\""+ timepoint_id+"\"><span class = \"transcript_notation\">["+ text + "]</span></div>\n"
            result << "                  </div> <!-- transcript_row -->\n"
          end
        end
      end

      result << "                </div> <!-- transcript_chunk -->\n"
    end

    result << "              </div> <!-- transcript_table -->\n"

    return result
  end


  def parse_notations(node)
    result = ""

    node.children.each do |child|
      childName = child.name

      if (childName == "text")
        result += child.text
      elsif (childName == "unclear")
        result += "<span class=\"transcript_notation\">[" + child.text + "]</span>"
      elsif (childName == "event" || childName == "gap" || childName == "vocal" || childName == "kinesic")
        unless child.attributes.empty?
        desc = child.attributes["desc"]
          unless desc.nil?
            result += "<span class=\"transcript_notation\">[" + desc + "]</span>"
          end
        end
      end
    end

    return result
  end


  private # all methods that follow will be made private: not accessible for outside objects

  # convert a transcript time in milliseconds into displayable strings for UI
  def displayable_time(milliseconds)
    int_total_seconds = milliseconds.to_i / 1000 # truncated to the second
    int_minutes = int_total_seconds / 60
    int_just_seconds = int_total_seconds - (int_minutes * 60) # the seconds for seconds:minutes (0:00) display
    string_minutes = int_minutes.to_s
    string_just_seconds = int_just_seconds.to_s

    if (int_just_seconds < 10)
      string_just_seconds = "0" + string_just_seconds
    end

    return string_minutes, string_just_seconds, int_total_seconds.to_s
  end


end
