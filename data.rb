#!/opt/local/bin/ruby1.9
# -*- coding: utf-8 -*-
class Array
  include Enumerable


  def at_set(n)
    at(n - 1)
  end

  alias_method :formant, :at_set

  def f1
    formant(1)
  end

  def f2
    formant(2)
  end

  def f3
    formant(3)
  end

  def sum
    inject(0) { |total, value| total + value }
  end

  def average
    nil unless all? { |data| data.kind_of? Fixnum }
    sum.to_f / (length)
  end

  def sample_variance
    avg = average
    if avg.nil?
      nil
    else
      (inject(0) {|total, i| total + (i - avg)**2 }).to_f / (length - 1)
    end
  end

  def std_dev
    svar = sample_variance
    if svar.nil?
      nil
    else
      Math.sqrt(svar)
    end
  end

end

class Hash
  include Enumerable
  def R_tabulate_averages(title="Utterance", labels=true)
    "#{"#{title} f1 f2 f3" if labels} \n#{
    map { |word, formants| "#{word} #{ formants.map { |f| f.average.to_s }.join(' ') }" }.join("\n")
    }"
  end

  def each_monophthong
    each_vowel do |v|
      yield v if v.monophthong?
    end
  end

  def each_diphthong
    diphthongs = keys.delete_if {|v| v.monophthong?}.sort
    single_set = Array.new
    diphthongs.each do |x|
      single_set.push(x)
      if single_set.length == 3
        yield [single_set.at(1), single_set.at(2), single_set.at(0)]
        single_set.clear
      end
    end
  end

  alias_method :each_vowel, :each_key
end

class String 
  def diphthong?
    include?("_[") and include? "]"
  end

  def monophthong?
    not diphthong?
  end

end

def transcribe(vowel, narrow=true)
  if narrow
    case vowel.downcase
    when "heed" then "i"
    when "hid" then "ɪ"
    when "hayed" then "e"
    when "head" then "ɛ"
    when "had" then "a"
    when "Mater" then "a"
    when "aunt" then "a"
    when "ant" then "a"
    when "matter" then "a"
    when "hod" then "ɑ"
    when "hawed" then "ɔ"
    when "hoed" then "o"
    when "hudd" then "ʌ"
    when "hood" then "ʊ"
    when "petite" then "i"
    when "Pam" then "a"
    when "palm" then "a"
    end 
  end
end

base_context = {
  "heed" => [[300,288,300,310,280],[2250,2300,2560,2290,2280],[2820,2825,2840,2870,2810]],
  "hid" => [[400,400,400,410,410],[1950,1960,2010,1950,1910],[2700,2400,2640,2540,2550]],
  "hayed" => [[460,450,480,470,480],[2120,2250,2140,2210,2110],[2370,2410,2430,2440,2410]],
  "head" => [[600,590,600,610,620],[1800,1900,1780,1750,1850],[2500,2450,2510,2530,2400]],
  "had" => [[800,830,830,820,820],[1600,1590,1580,1580,1570],[2400,2350,2340,2410,2380]],
  "Mater" => [[750,830,790,850,840],[1500,1550,1510,1520,1530],[2400,2380,2200,2280,2300]],
  "aunt" => [[890,880,880,880,880],[1520,1570,1600,1560,1590],[2300,2340,2190,2285,2400]],
  "ant" => [[820,860,850,820,850],[1500,1560,1540,1460,1490],[2400,2340,2340,2330,2390]],
  "matter" => [[800,870,880,830,860],[1500,1500,1500,1510,1530],[2490,2370,2300,2380,2380]],
  "hod" => [[700,780,750,680,670],[1150,1170,1140,1110,1100],[2400,2410,2260,2370,2380]],
  "hawed" => [[600,600,620,610,630],[980,970,980,1020,1010],[2500,2410,2410,2410,2430]],
  "hoed" => [[410,360,380,380,390],[780,780,840,830,810],[2460,2400,2410,2420,2430]],
  "hudd" => [[550,480,450,440,470],[1100,1050,1190,1060,1180],[2350,2340,2330,2330,2340]],
  "hood" => [[510,470,470,460,470],[1100,1030,1090,1050,1070],[2400,2340,2240,2310,2320]],
  "who'd" => [[300,300,320,330,316],[1090,1020,1080,1090,1060],[2190,2260,2210,2300,2260]],# Diphthong?
  "hide_[initial]" => [[680,680,680,690,650],[1330,1240,1350,1360,1250],[2380,2370,2470,2360,2410]],
  "hide_[trans]" => [[570,600,590,580,600],[1610,1540,1600,1630,1510],[2360,2370,2390,2360,2350]],
  "hide_[final]" => [[290,310,300,310,300],[2030,2060,2100,1930,2070],[2420,2370,2420,2410,237]],
  "Hoyd_[initial]" => [[580,570,600,570,580],[890,910,1000,1010,1010],[2480,2400,2380,2430,2510]],
  "Hoyd_[trans]" => [[550,540,550,540,540],[1440,1440,1470,1470,1480],[2330,2330,2320,2330,2320]],
  "Hoyd_[final]" => [[380,410,370,390,400],[2010,1940,1980,1950,1940],[2410,2290,2340,2430,2310]],
  "how'd_[initial]" => [[570,600,620,600,570],[1780,1800,1720,1780,1850],[2390,2340,2320,2450,2400]],
  "how'd_[trans]" => [[520,500,520,520,520],[1430,1390,1410,1420,1400],[2300,2290,2220,2340,2260]],
  "how'd_[final]" => [[410,420,410,390,400],[1100,1100,1080,1100,1140],[2270,2270,2210,2290,2300]],
  "petite" => [[410,410,420,340,395],[1800,1610,1630,1800,1710],[2490,2500,2600,2400,2500]],
  "Pam" => [[930,930,920,870,930],[1460,1560,1450,1430,1400],[2300,2300,2120,2230,2150]],
  "palm" => [[880,900,900,880,900],[1510,1490,1490,1490,1520],[2300,2300,2160,2300,2400]]
}

r_formant_stable = {
  "beard" => [[400,400,410,400,390],[1950,1960,1920,1920,1960],[2400,2550,2400,2010,2410]],
  "gird" => [[500,510,480,520,520],[1500,1530,1580,1460,1510],[2100,2060,2160,2000,1990]],
  #"bared" => [[510,510,"NA",500,5010],[1920,1930,"NA",1940,1930],[2400,2420,"NA",2470,2400]], # Not present in set 3
  "heard" => [[580,570,590,570,560],[1400,1350,1490,1430,1330],[1950,2050,2010,1970,1940]],
  "hard" => [[700,750,700,700,700],[1600,1610,1600,1610,1650],[2100,2200,2150,2190,2100]],
  "horticulture" => [[590,530,530,520,530],[980,810,810,960,920],[2350,2470,2440,2300,2340]],
  "lord" => [[500,500,510,510,530],[1000,970,1020,1030,930],[2400,2360,2340,2390,2390]],
  "hoard" => [[450,430,440,460,440],[850,860,840,850,840],[2440,2410,2430,2450,2410]],
  "Hurd" => [[550,580,550,560,550],[1400,1330,1280,1410,1290],[2000,2030,2010,1980,1970]],
  "gourd" => [[400,420,430,430,420],[800,900,780,880,840],[2300,2300,2310,2330,2280]],
  "hired" => [[650,520,660,640,650],[1210,1400,1310,1260,1240],[2400,2280,2300,2400,2350]] # Dipthong?
}

r_trans = {
  "beard" => [[400,400,410,400,410],[1700,1780,1780,1870,1870],[2100,2200,2100,2000,2081]],
  "gird" => [[510,530,530,520,510],[1490,1460,1400,1440,1410],[1950,1950,1950,1910,1870]],
  "bared" => [[500,500,510,510,510],[1700,1680,1690,1690,1700],[2000,2050,2070,2090,2080]],
  "heard" => [[540,550,530,500,520],[1500,1430,1500,1480,1400],[1950,1990,2000,1920,1860]], # he trips up here
  "hard" => [[500,550,590,580,580],[1600,1600,1590,1600,1620],[2050,2100,2150,2100,2120]],
  "horticulture" => [[560,530,520,520,500],[1130,1110,1050,1090,1090],[1860,1690,1790,1780,1810]],
  "lord" => [[500,490,490,500,510],[900,1070,920,1050,1060],[2300,2050,2300,2210,2310]],
  "hoard" => [[480,460,430,440,430],[990,1040,840,1050,900],[2110,1990,2430,2070,2070]],
  "Hurd" => [[510,520,500,510,520],[1500,1440,1440,1450,1440],[1900,1930,1910,1950,1940]],
  "gourd" => [[500,480,470,480,470],[1000,1070,1100,1070,1030],[2000,1980,1900,2000,1990]],
  "hired" => [[540,520,550,550,551],[1600,1700,1500,1580,1540],[2200,2230,2200,2300,2280]]
}

r_formant_end = {
  "beard" => [[400,400,410,400,400],[1600,1560,1630,1560,1620],[2190,2100,2030,1890,1890]],
  "gird" => [[500,450,440,440,440],[1450,1520,1550,1530,1560],[1900,1950,1950,1940,1870]],
  "bared" => [[510,510,500,460,510],[1500,1520,1520,1510,1560],[2000,1900,1900,1980,1950]],
  "heard" => [[500,430,450,430,430],[1600,1600,1540,1540,1500],[1900,1900,1900,1900,1830]],
  "hard" => [[500,470,500,500,500],[1650,1570,1560,1560,1570],[1900,2070,2100,2000,2020]],
  "horticulture" => [[480,510,490,500,480],[1230,1180,1180,1190,1200],[1720,1550,1610,1590,158]],
  "lord" => [[500,510,480,500,510],[1100,1200,1220,1300,1300],[1950,1870,1930,1910,1880]], # bit dodge
  "hoard" => [[450,420,450,440,430],[1280,1260,1255,1255,1200],[1950,1870,1930,1890,1880]],
  "Hurd" => [[500,480,460,450,460],[1600,1460,1460,1460,1470],[2000,1900,1900,1930,1930]],
  "gourd" => [[480,460,440,450,450],[1300,1260,1230,1270,1220],[1900,1900,1900,1920,1910]],
  "hired" => [[430,440,450,430,420],[1600,1590,1700,1700,1670],[2100,2020,2100,2060,2100]]
}

  


def make_tables(data, caption)
1.upto(5) do |set_num|
puts <<EOF;
\\begin{table}[!h]
\\label{set#{set_num}mono}
\\begin{center}
\\begin{tabular}{|c|c|c|c|c|}
\\hline
Utterance & Vowel & $F1$ & $F2$ & $F3$ \\\\
\\hline
#{
table = "\n"
data.each_monophthong do |m|
    table += "\\emph{" + m + "}" + " & " + "[\\ipa{" + transcribe(m) + "}]" 
    1.upto(3) do |n|
      table += " & " + data[m].formant(n).at_set(set_num).to_s
    end
    table += " \\\\ \n" 
end
table
}
\\hline
\\end{tabular}
\\end{center}
\\caption{Set #{set_num} #{caption}}
\\end{table}
\n\n\n
EOF
end
end

def make_ave_tables(data, caption)
puts <<EOF;
\\begin{table}[!h]
\\label{avemononon}
\\begin{center}
\\begin{tabular}{|c|c|c|c|c|}
\\hline
Utterance & $F1$ (Hz) & $F2$ (Hz) & $F3$ (Hz) \\\\
\\hline
#{
table = "\n"
data.each_monophthong do |m|
    table += "\\emph{" + m + "}" 
    1.upto(3) do |n|
      table += " & " + data[m].formant(n).average.to_s + " ($\\sigma \\approx #{data[m].formant(n).std_dev.round(2)}$)"
    end
    table += " \\\\ \n" 
end
table
}
\\hline
\\end{tabular}
\\end{center}
\\caption{\\textsf{#{caption}}}
\\end{table}
\n\n\n
EOF
end

def make_diphthong_tables(data)
  initials = Array.new
  transitions = Array.new
  finals = Array.new

  data.each_diphthong do |d|
    [finals, transitions, initials].each { |s| s.push(d.pop) }
  end

[initials, transitions, finals].each do |s|

label = case
        when s[-1].include?("initial") then "initial"
        when s[-1].include?("trans") then "transition"
        when s[-1].include?("final") then "final"
        end

puts <<EOF;  
\\begin{table}[!h]
\\begin{center}
\\begin{tabular}{|c|c|c|c|c|}
\\hline
Utterance & $F1$ (Hz) & $F2$ (Hz) & $F3$ (Hz) \\\\
\\hline
#{
table = String.new
s.each do |i|
  table += "\\emph{" + i.split("_").shift + "}"
  1.upto(3) do |f|
    table += " & " + data[i].formant(f).average.to_s
  end
end
table
}
\\hline
\\end{tabular}
\\end{center}
\\caption{#{label}}
\\label{#{label}}
\\end{table}\n
EOF
end
end

if __FILE__ == $0
  #make_ave_tables(r_formant_end, "Average formant frequencies for monophthongs in non-rhotic context")
  make_diphthong_tables(base_context)
end
