# toolcap_monoids

some standard tool_monoids.

* `toolcap_monoids.full_punch`

  modifies the "full punch" interval. multiplicative. values > 1 will increase time between full punches,
  < 1 will decrease the same.

* `toolcap_monoids.dig_speed`

  modifies dig times. multiplicative. values > 1 will increase dig time, < 1 will decrease dig time.
  values can also be tables mapping specific groupcaps to specific multipliers.

* `toolcap_monoids.durability`

  modifies tool uses. multiplicative. values > 1 will increase durability, < 1 will decrease durability.
  values can also be tables mapping specific groupcaps to specific multipliers.

* `toolcap_monoids.damage`

  modifies tool damage groups. *additive*, not multiplicative.
  values must be tables mapping damage groups to the increase (or decrease) in damage for that group.
