-record(term, {type, value, left, right}).

-record(seven_segment, {top=off, topleft=off, topright=off, middle=off, bottomleft=off, bottomright=off, bottom=off}).
-record(state, {value, segment}).
-record(display, {states=[], segment_to_value=#{}, value_to_segment=#{}}).

-define(ZERO, #state{
  value=0,
  segment=#seven_segment{top=on, topleft=on, topright=on, bottomleft=on, bottomright=on, bottom=on}
}).

-define(ONE, #state{
  value=1,
  segment=#seven_segment{topright=on, bottomright=on}
}).

-define(TWO, #state{
  value=2,
  segment=#seven_segment{top=on, topright=on, middle=on, bottomleft=on, bottom=on}
}).

-define(THREE, #state{
  value=3,
  segment=#seven_segment{top=on, topright=on, middle=on, bottomright=on, bottom=on}
}).

-define(FOUR, #state{
  value=4,
  segment=#seven_segment{topleft=on, topright=on, middle=on, bottomright=on}
}).

-define(FIVE, #state{
  value=5,
  segment=#seven_segment{top=on, topleft=on, middle=on, bottomright=on, bottom=on}
}).

-define(SIX, #state{
  value=6,
  segment=#seven_segment{top=on, topleft=on, middle=on, bottomleft=on, bottomright=on, bottom=on}
}).

-define(SEVEN, #state{
  value=7,
  segment=#seven_segment{top=on, topright=on, bottomright=on}
}).

-define(EIGHT, #state{
  value=8,
  segment=#seven_segment{top=on, topleft=on, topright=on, middle=on, bottomleft=on, bottomright=on, bottom=on}
}).

-define(NINE, #state{
  value=9,
  segment=#seven_segment{top=on, topleft=on, topright=on, middle=on, bottomright=on, bottom=on}
}).
