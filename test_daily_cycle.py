import unittest
from gameplay.daily_needs import Farmer
from gameplay.day_night import lighting_at

class DailyNeedsTests(unittest.TestCase):
    def test_idle_advances_clock(self):
        farmer = Farmer()
        farmer.advance(60)
        self.assertEqual(farmer.clock, "08:00")

    def test_hunger_and_farming_energy(self):
        farmer = Farmer()
        farmer.advance(240, "farming")
        self.assertGreater(farmer.hunger, 0)
        self.assertLess(farmer.energy, 100)

    def test_hunger_drain_and_slower_movement_even_with_full_energy(self):
        fed = Farmer(energy=100.0, hunger=10.0)
        hungry = Farmer(energy=100.0, hunger=80.0)
        starving = Farmer(energy=100.0, hunger=95.0)
        self.assertEqual(fed.movement_multiplier(), 1.0)
        self.assertAlmostEqual(hungry.movement_multiplier(), 0.88)
        self.assertAlmostEqual(starving.movement_multiplier(), 0.76)

        fed.advance(60, "idle")
        hungry.advance(60, "idle")
        self.assertLess(hungry.energy, fed.energy)
        self.assertLess(hungry.movement_multiplier(), fed.movement_multiplier())
        self.assertEqual(fed.clock, hungry.clock)

    def test_food_restores_movement_without_forcing_sleep(self):
        farmer = Farmer(minute=23 * 60, energy=60.0, hunger=95.0)
        before = farmer.movement_multiplier()
        farmer.eat()
        self.assertLess(farmer.hunger, 65.0)
        self.assertEqual(farmer.movement_multiplier(), 1.0)
        self.assertLess(before, farmer.movement_multiplier())
        self.assertEqual(farmer.clock, "23:00")

    def test_tired_and_hungry_penalties_compound_but_stay_playable(self):
        farmer = Farmer(energy=10.0, hunger=95.0)
        self.assertAlmostEqual(farmer.movement_multiplier(), 0.62 * 0.76)
        farmer.advance(30, "walking")
        self.assertGreater(farmer.minute, 7 * 60)
        self.assertGreater(farmer.movement_multiplier(), 0.0)

    def test_sleep_restores_energy_and_advances_time(self):
        farmer = Farmer(minute=22*60, energy=20, fatigue=70)
        farmer.sleep(8)
        self.assertEqual(farmer.clock, "06:00")
        self.assertGreater(farmer.energy, 20)
        self.assertLess(farmer.fatigue, 70)

    def test_sky_phases(self):
        self.assertEqual(lighting_at(6*60).phase, "sunrise")
        self.assertEqual(lighting_at(12*60).phase, "day")
        self.assertEqual(lighting_at(18*60).phase, "sunset")
        self.assertEqual(lighting_at(23*60).phase, "night")
        self.assertTrue(lighting_at(23*60).house_lights)

if __name__ == "__main__":
    unittest.main()
