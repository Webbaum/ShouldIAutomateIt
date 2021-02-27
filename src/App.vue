<template>
  <div>
    <div class="container mx-auto py-6">
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
            hint="in Minutes"
            type="integer"
            post="min"
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

      <div class="my-10 py-4 px-4 border rounded-sm bg-white shadow-sm border-gray-400">
        <h3 class="text-center font-medium text-lg tracking-wider leading-6 mb-5">Amortization in Weeks</h3>
        <table class="w-full tabular-nums leading-none">
          <tbody>
            <tr class="border-b">
              <td class="px-2 py-1 border-r"></td>
              <td
                v-for="dur of autoDurationSpread"
                :key="dur"
                class="text-center font-medium px-2 py-1"
                v-text="dur"
              />
            </tr>
            <tr
              v-for="rec of taskRecurrenceSpread"
              :key="rec"
            >
              <td class="px-2 py-1 text-right border-r font-medium" v-text="rec" />
              <td
                v-for="dur of autoDurationSpread"
                :key="dur"
                class="text-center px-2 py-1"
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

  export default {
    components: { vInput },
    data () {
      return  {
        taskDuration: 5, // Duration in Minutes
        taskRecurrence: 5, // Recurrences per KW
        taskHourlyCosts: 20,
        autoDuration: 60, // Duration in Minutes
        autoHourlyCosts: 100
      }
    },
    computed: {
      taskRecurrenceSpread () {
        return [0.5, 0.75, 1, 1.25, 1.5].map(d => d * this.taskDuration)
      },
      autoDurationSpread () {
        return [0.5, 0.75, 1, 1.25, 1.5].map(d => Math.round(d * this.autoDuration))
      },
      taskCostPerMinute () {
        return this.taskHourlyCosts / 60
      },
      autoCostPerMinute () {
        return this.autoHourlyCosts / 60
      }
    },
    methods: {
      getAmortization (recurrence, duration) {
        const task = this.taskDuration * this.taskCostPerMinute * recurrence
        const auto = duration * this.autoCostPerMinute
        return formatNum(Math.ceil(auto / task))
      }
    }
  }
</script>
