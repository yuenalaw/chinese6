import math

class SRSHelper:
    """
    returns the new interval, repetitions and ease factor
    """
    def sm2(self, prev_repetitions, prev_ease_factor, prev_interval, quality):
        if quality >= 3:
            prev_interval = 1 if prev_repetitions == 0 else 6 if prev_repetitions == 1 else \
            math.ceil(prev_interval * prev_ease_factor)
            prev_repetitions += 1
            prev_ease_factor = prev_ease_factor + (0.1 - (5-quality) * (0.08 + (5-quality) * 0.02))
        else:
            prev_repetitions, prev_interval = 0,1
        
        prev_ease_factor = max(prev_ease_factor, 1.3)
        return prev_interval, prev_repetitions, prev_ease_factor