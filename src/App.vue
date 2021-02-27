<template>
  <div>
    <div class="container mx-auto py-14 space-y-14">
      <h1 class="text-center text-3xl tracking-wider mb-10 font-semibold uppercase">Should I automate It?</h1>
      <div class="flex justify-center -mx-6">
        <div class="mx-6 space-y-4 py-4 px-4 max-w-xs border rounded-sm bg-white shadow-sm border-gray-400">
          <h3 class="text-center font-medium text-lg tracking-wider leading-6 mb-5">Task</h3>
          <v-input
            title="Duration"
            hint="in Minutes"
            type="integer"
            post="min"
            v-model="taskDuration"
            required
          />
          <v-input
            title="Recurrence"
            hint="per Week"
            type="number"
            post="x"
            v-model="taskRecurrence"
            required
          />
          <v-input
            title="Costs"
            hint="per Hour"
            post="€/h"
            type="number"
            v-model="taskHourlyCosts"
            required
          />
        </div>
        <div class="mx-6 space-y-4 py-4 px-4 max-w-xs border rounded-sm bg-white shadow-sm border-gray-400">
          <h3 class="text-center font-medium text-lg tracking-wider leading-6 mb-5">Automation</h3>
          <v-input
            title="Duration"
            hint="in Hours"
            type="integer"
            post="hours"
            v-model="autoDuration"
            required
          />
          <v-input
            title="Costs"
            hint="per Hour"
            post="€/h"
            type="number"
            v-model="autoHourlyCosts"
            required
          />
        </div>
      </div>

      <div class="py-4 border rounded-sm bg-white shadow-sm border-gray-400">
        <h3 class="px-4 text-center font-medium text-lg tracking-wider leading-6 mb-5">Amortization in Weeks</h3>
        <table class="w-full table-fixed tabular-nums leading-none whitespace-nowrap">
          <tbody>
            <tr>
              <td class="px-2 w-10 py-2"></td>
              <td class="px-2 py-2 border-r"></td>
              <td :colspan="autoDurationSpread.length" class="text-center px-2 py-1 font-medium">Automation Duration</td>
            </tr>
            <tr class="border-b font-medium">
              <td class="px-2 py-2"></td>
              <td class="px-2 py-2 border-r"></td>
              <td
                v-for="dur of autoDurationSpread"
                :key="dur"
                class="text-center px-2 py-2"
                v-text="dur"
              />
            </tr>
            <tr
              v-for="(rec, i) of taskRecurrenceSpread"
              :key="rec"
            >
              <td
                v-if="i === 0"
                class="px-0 py-0 w-10 relative"
                :rowspan="taskRecurrenceSpread.length"
              >
                <div class="relative w-full h-full bg-red-500">
                  <div class="absolute h-full w-10 z-10 flex flex-col justify-center items-center">
                    <div class="absolute font-medium transform -rotate-90">Recurrences per Week</div>
                  </div>
                </div>
              </td>
              <td class="px-2 py-2 text-right border-r font-medium" v-text="rec" />
              <td
                v-for="dur of autoDurationSpread"
                :key="dur"
                class="text-center px-2 py-2"
                v-html="getAmortization(rec, dur)"
              />
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script>
  import vInput from './components/v-input.vue'
  import { formatNum } from '@krknet/fe/helpers'

  import { scaleLinear } from 'd3-scale'

  export default {
    components: { vInput },
    data () {
      return  {
        taskDuration: 5, // Duration in Minutes
        taskRecurrence: 5, // Recurrences per KW
        taskHourlyCosts: 20,
        autoDuration: 5, // Duration in Hours
        autoHourlyCosts: 100
      }
    },
    computed: {
      taskRecurrenceSpread () {
        return scaleLinear().domain([this.taskRecurrence * 0.5, this.taskRecurrence * 1.5]).nice().ticks(5)
      },
      autoDurationSpread () {
        return scaleLinear().domain([this.autoDuration * 0.5, this.autoDuration * 1.5]).nice().ticks(5)
      },
      taskCostPerMinute () {
        return this.taskHourlyCosts / 60
      }
    },
    methods: {
      getAmortization (recurrence, duration) {
        const task = this.taskDuration * this.taskCostPerMinute * recurrence
        const auto = duration * this.autoHourlyCosts
        return formatNum(Math.ceil(auto / task))
      }
    }
  }
</script>
